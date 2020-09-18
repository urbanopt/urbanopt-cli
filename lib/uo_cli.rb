#!/usr/bin/ ruby

# *********************************************************************************
# URBANopt™, Copyright (c) 2019-2020, Alliance for Sustainable Energy, LLC, and other
# contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this list
# of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution.
#
# Neither the name of the copyright holder nor the names of its contributors may be
# used to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
# *********************************************************************************

require 'uo_cli/version'
require 'optimist'
require 'urbanopt/geojson'
require 'urbanopt/scenario'
require 'urbanopt/reopt'
require 'urbanopt/reopt_scenario'
require 'csv'
require 'fileutils'
require 'json'
require 'openssl'
require 'open3'
require_relative '../developer_nrel_key'
require 'pycall/import'
include PyCall::Import

module URBANopt
  module CLI
    class UrbanOptCLI
      COMMAND_MAP = {
        'create' => 'Make new things - project directory or files',
        'run' => 'Use files in your directory to simulate district energy use',
        'opendss' => 'Run OpenDSS simulation',
        'process' => 'Post-process URBANopt simulations for additional insights',
        'visualize' => 'Visualize and compare results for features and scenarios',
        'delete' => 'Delete simulations for a specified scenario'
      }.freeze

      def initialize
        @subopts = nil
        @command = nil
        @mainopts = Optimist.options do
          version VERSION
          banner "\nURBANopt CLI version: #{version}"
          banner "\nUsage:"
          banner "  uo [options] [<command> [suboptions]]\n \n"
          banner 'Options:'
          opt :version, 'Print version and exit'  ## add this here or it goes to bottom of help
          opt :help, 'Show this help message'     ## add this here or it goes to bottom of help
          # opt :no_pager, "Disable paging"
          stop_on COMMAND_MAP.keys
          banner "\nCommands:"
          COMMAND_MAP.each { |cmd, desc| banner format('  %-10s %s', cmd, desc) }
          banner "\nFor help with a specific command: uo <command> --help"
          banner "\nAdditional config options can be set with the 'runner.conf' file inside your project folder"
          banner 'Fewer warnings are presented when using full paths and the user is not inside the project folder'
        end
        return if ARGV.empty?
        @command = ARGV.shift
        send("opt_#{@command}") ## dispatch to command handling method
      end

      # Define creation commands
      def opt_create
        cmd = @command
        @subopts = Optimist.options do
          banner "\nURBANopt #{cmd}:\n \n"

          opt :project_folder, "\nCreate project directory in your current folder. Name the directory\n" \
          "Add additional tag to specify the method for creating geometry, or use the default urban geometry creation method to create building geometry from geojson coordinates with core and perimeter zoning\n" \
          "Example: uo create --project-folder urbanopt_example_project", type: String, short: :p

          opt :create_bar, "\nCreate building geometry and add space types using the create bar from building type ratios measure\n" \
          "Refer to https://docs.urbanopt.net/ for more details about the workflow\n" \
          "Used with --project-folder\n" \
          "Example: uo create --project-folder urbanopt_example_project --create-bar\n", short: :c

          opt :floorspace, "\nCreate building geometry and add space types from a floorspace.js file\n" \
          "Refer to https://docs.urbanopt.net/ for more details about the workflow\n" \
          "Used with --project-folder\n" \
          "Example: uo create --project-folder urbanopt_example_project --floorspace\n", short: :f

          opt :residential, "\n Create project directory that supports running residential workflows in addition to the default commercial workflows\n" \
          "Used with --project-folder\n" \
          "Example: uo create --project-folder urbanopt_example_project --residential\n", :short => :d

          opt :empty, "\nUse with --project-folder argument to create an empty project folder\n" \
          "Then add your own Feature file in the project directory you created,\n" \
          "add Weather files in the weather folder and add OpenStudio models of Features\n" \
          "in the Feature File, if any, in the osm_building folder\n" \
          "Example: uo create --empty --project-folder urbanopt_example_project\n", short: :e

          opt :overwrite, "\nUse with --project-folder argument to overwrite existing project folder and replace with new project folder.\n" \
          "May be combined with --empty as well to overwrite existing project folder and replace with new empty project folder.\n" \
          "Example: uo create --overwrite --empty --project-folder urbanopt_project_folder_I_want_destroyed\n", short: :o

          opt :scenario_file, "\nAutomatically create a ScenarioFile containing the features in FeatureFile for each scenario\n" \
          "Provide the FeatureFile used to create the ScenarioFile\n" \
          "Example: uo create --scenario-file example_project.json\n", type: String, short: :s

          opt :single_feature, "\nCreate a ScenarioFile with only a single feature\n" \
          "Use the FeatureID from your FeatureFile\n" \
          "Requires 'scenario-file' also be specified, to say which FeatureFile will create the ScenarioFile\n" \
          "Example: uo create --single-feature 2 --scenario-file example_project.json\n", type: String, short: :i

          opt :reopt_scenario_file, "\nCreate a ScenarioFile that includes a column defining the REopt assumptions file\n" \
          "Specify the existing ScenarioFile that you want to extend with REopt functionality\n" \
          "Example: uo create --reopt-scenario-file baseline_scenario.csv\n", type: String, short: :r

        end
      end

      # Define running commands
      def opt_run
        cmd = @command
        @subopts = Optimist.options do
          banner "\nURBANopt #{cmd}:\n \n"

          opt :reopt, "\nSimulate with additional REopt functionality. Must do this before post-processing with REopt"

          opt :scenario, "\nRun URBANopt simulations for <scenario>\n" \
          "Requires --feature also be specified\n" \
          'Example: uo run --scenario baseline_scenario-2.csv --feature example_project.json', default: 'baseline_scenario.csv', required: true

          opt :feature, "\nRun URBANopt simulations according to <featurefile>\n" \
          "Requires --scenario also be specified\n" \
          'Example: uo run --scenario baseline_scenario.csv --feature example_project.json', default: 'example_project.json', required: true
        end
      end

      # Define opendss commands
      def opt_opendss
        cmd = @command
        @subopts = Optimist.options do
          banner "\nURBANopt #{cmd}:\n\n"

          opt :scenario, "\nRun OpenDSS simulations for <scenario>\n" \
          "Requires --feature also be specified\n" \
          'Example: uo opendss --scenario baseline_scenario-2.csv --feature example_project.json', default: 'baseline_scenario.csv', required: true

          opt :feature, "\nRun OpenDSS simulations according to <featurefile>\n" \
          "Requires --scenario also be specified\n" \
          'Example: uo opendss --scenario baseline_scenario.csv --feature example_project.json', default: 'example_project.json', required: true

          opt :equipment, "\nRun OpenDSS simulations using <equipmentfile>. If not specified, the electrical_database.json from urbanopt-ditto-reader will be used.\n" \
          'Example: uo opendss --scenario baseline_scenario.csv --feature example_project.json'

          opt :reopt, "\nRun with additional REopt functionality."
        end
      end

      # Define post-processing commands
      def opt_process
        cmd = @command
        @subopts = Optimist.options do
          banner "\nURBANopt #{cmd}:\n \n"

          opt :default, "\nStandard post-processing for your scenario"

          opt :opendss, "\nPost-process with OpenDSS"

          opt :reopt_scenario, "\nOptimize for entire scenario with REopt\n" \
          'Example: uo process --reopt-scenario'

          opt :reopt_feature, "\nOptimize for each building individually with REopt\n" \
          'Example: uo process --reopt-feature'

          opt :scenario, "\nSelect which scenario to optimize", default: 'baseline_scenario.csv', required: true

          opt :feature, "\nSelect which FeatureFile to use", default: 'example_project.json', required: true

        end
      end

      # Define visualization commands
      def opt_visualize
        cmd = @command
        @subopts = Optimist.options do
          banner "\nURBANopt #{cmd}:\n \n"

          opt :scenarios, "\nVisualize results for all scenarios\n" \
            "Provide the FeatureFile whose scenario results you want to visualize\n" \
            "Example: uo visualize --scenarios example_project.json", type: String

          opt :features, "\nVisualize results for all features in a scenario\n" \
            "Provide the Scenario whose feature results you want to visualize\n" \
            "Example: uo visualize --features baseline_scenario.csv", type: String

        end
      end

      def opt_delete
        cmd = @command
        @subopts = Optimist.options do
          banner "\nURBANopt #{cmd}:\n \n"

          opt :scenario, "\nDelete simulation files for this scenario", default: 'baseline_scenario.csv', required: true
        end
      end

      attr_reader :mainopts, :command, :subopts
    end

    # Initialize the CLI class
    @opthash = UrbanOptCLI.new

    # Pull out feature and scenario filenames and paths
    if @opthash.subopts[:scenario_file]
      @feature_path, @feature_name = File.split(File.absolute_path(@opthash.subopts[:scenario_file]))
    end
    # FIXME: Can this be combined with the above block? This isn't very DRY
    # One solution would be changing scenario_file to feature.
    #   Would that be confusing when creating a ScenarioFile from the FeatureFile?
    if @opthash.subopts[:feature]
      @feature_path, @feature_name = File.split(File.absolute_path(@opthash.subopts[:feature]))
    end
    if @opthash.subopts[:scenario]
      @root_dir, @scenario_file_name = File.split(File.absolute_path(@opthash.subopts[:scenario]))
    end

    # Simulate energy usage as defined by ScenarioCSV\
    def self.run_func
      name = File.basename(@scenario_file_name, File.extname(@scenario_file_name))
      run_dir = File.join(@root_dir, 'run', name.downcase)
      csv_file = File.join(@root_dir, @scenario_file_name)
      featurefile = File.join(@root_dir, @feature_name)
      mapper_files_dir = File.join(@root_dir, 'mappers')
      reopt_files_dir = File.join(@root_dir, 'reopt/')
      num_header_rows = 1

      if @feature_id
        feature_run_dir = File.join(run_dir, @feature_id)
        # If run folder for feature exists, remove it
        FileUtils.rm_rf(feature_run_dir) if File.exist?(feature_run_dir)
      end

      feature_file = URBANopt::GeoJSON::GeoFile.from_file(featurefile)
      if @opthash.subopts[:reopt] == true || @opthash.subopts[:reopt_scenario] == true || @opthash.subopts[:reopt_feature] == true
        # TODO: Better way of grabbing assumptions file than the first file in the folder
        reopt_files_dir_contents_list = Dir.children(reopt_files_dir.to_s)
        reopt_assumptions_filename = File.basename(reopt_files_dir_contents_list[0])
        scenario_output = URBANopt::Scenario::REoptScenarioCSV.new(name, @root_dir, run_dir, feature_file, mapper_files_dir, csv_file, num_header_rows, reopt_files_dir, reopt_assumptions_filename)
      else
        scenario_output = URBANopt::Scenario::ScenarioCSV.new(name, @root_dir, run_dir, feature_file, mapper_files_dir, csv_file, num_header_rows)
      end
      scenario_output
    end

    # Create a scenario csv file from a FeatureFile
    # params\
    # +feature_file_path+:: _string_ Path to a FeatureFile
    def self.create_scenario_csv_file(feature_id)
      feature_file_json = JSON.parse(File.read(File.absolute_path(@opthash.subopts[:scenario_file])), symbolize_names: true)
      Dir["#{@feature_path}/mappers/*.rb"].each do |mapper_file|
        mapper_name = File.basename(mapper_file, File.extname(mapper_file))
        scenario_file_name = if feature_id == 'SKIP'
                               "#{mapper_name.downcase}_scenario.csv"
                             else
                               "#{mapper_name.downcase}_scenario-#{feature_id}.csv"
                             end
        CSV.open(File.join(@feature_path, scenario_file_name), 'wb', write_headers: true,
                                                                     headers: ['Feature Id', 'Feature Name', 'Mapper Class']) do |csv|
          feature_file_json[:features].each do |feature|
            if feature_id == 'SKIP'
              # ensure that feature is a building
              if feature[:properties][:type] == 'Building'
                csv << [feature[:properties][:id], feature[:properties][:name], "URBANopt::Scenario::#{mapper_name}Mapper"]
              end
            elsif feature_id == feature[:properties][:id]
              csv << [feature[:properties][:id], feature[:properties][:name], "URBANopt::Scenario::#{mapper_name}Mapper"]
            elsif
              # If Feature ID specified does not exist in the Feature File raise error
              unless feature_file_json[:features].any? { |hash| hash[:properties][:id].include?(feature_id.to_s) }
                abort("\nYou must provide Feature ID from FeatureFile!\n---\n\n")
              end
            end
          end
        end
      end
    end

    # Write new ScenarioFile with REopt column
    # params \
    # +existing_scenario_file+:: _string_ - Name of existing ScenarioFile
    def self.create_reopt_scenario_file(existing_scenario_file)
      existing_path, existing_name = File.split(File.absolute_path(existing_scenario_file))

      # make reopt folder
      Dir.mkdir File.join(existing_path, "reopt")

      # copy reopt files
      $LOAD_PATH.each { |path_item|
        if path_item.to_s.end_with?('example_files')
          reopt_files = File.join(path_item, "reopt")
          Pathname.new(reopt_files).children.each {|reopt_file| FileUtils.cp(reopt_file, File.join(existing_path, 'reopt'))}
        end
      }

      table = CSV.read(existing_scenario_file, headers: true, col_sep: ',')
      # Add another column, row by row:
      table.each do |row|
        row['REopt Assumptions'] = 'multiPV_assumptions.json'
      end
      # write new file
      CSV.open(File.join(existing_path, 'REopt_scenario.csv'), 'w') do |f|
        f << table.headers
        table.each { |row| f << row }
      end
    end

    # Create project folder
    # params\
    # +dir_name+:: _string_ Name of new project folder
    #
    # Includes weather for example location, a base workflow file, and mapper files to show a baseline and a high-efficiency option.
    def self.create_project_folder(dir_name, empty_folder = false, overwrite_project = false)
      if overwrite_project == true
        if Dir.exist?(dir_name)
          FileUtils.rm_rf(dir_name)
        end
      elsif overwrite_project == false
        if Dir.exist?(dir_name)
          abort("\nERROR:  there is already a directory here named #{dir_name}... aborting\n---\n\n")
        end
      end

      $LOAD_PATH.each { |path_item|
        if path_item.to_s.end_with?('example_files')

          if empty_folder == false

            Dir.mkdir dir_name
            Dir.mkdir File.join(dir_name, 'weather')
            Dir.mkdir File.join(dir_name, 'mappers')
            Dir.mkdir File.join(dir_name, 'osm_building')
            Dir.mkdir File.join(dir_name, 'visualization')

            # copy config file
            FileUtils.cp(File.join(path_item, "runner.conf"), dir_name)

            # copy gemfile
            FileUtils.cp(File.join(path_item, "Gemfile"), dir_name)

            # copy weather files
            weather_files = File.join(path_item, "weather")
            Pathname.new(weather_files).children.each {|weather_file| FileUtils.cp(weather_file, File.join(dir_name, "weather"))}

            # copy visualization files
            viz_files = File.join(path_item, "visualization")
            Pathname.new(viz_files).children.each {|viz_file| FileUtils.cp(viz_file, File.join(dir_name, "visualization"))}


            if @opthash.subopts[:floorspace] == false

              # copy feature file
              FileUtils.cp(File.join(path_item, "example_project.json"), dir_name)

              # copy osm
              FileUtils.cp(File.join(path_item, "osm_building/7.osm"), File.join(dir_name, "osm_building"))
              FileUtils.cp(File.join(path_item, "osm_building/8.osm"), File.join(dir_name, "osm_building"))
              FileUtils.cp(File.join(path_item, "osm_building/9.osm"), File.join(dir_name, "osm_building"))


              if @opthash.subopts[:create_bar] == false

                # copy the mappers
                FileUtils.cp(File.join(path_item, "mappers/Baseline.rb"), File.join(dir_name, "mappers"))
                FileUtils.cp(File.join(path_item, "mappers/HighEfficiency.rb"), File.join(dir_name, "mappers"))
                FileUtils.cp(File.join(path_item, "mappers/ThermalStorage.rb"), File.join(dir_name, "mappers"))

                # copy osw file
                FileUtils.cp(File.join(path_item, "mappers/base_workflow.osw"), File.join(dir_name, "mappers"))

              elsif @opthash.subopts[:create_bar] == true

                # copy the mappers
                FileUtils.cp(File.join(path_item, "mappers/CreateBar.rb"), File.join(dir_name, "mappers"))
                FileUtils.cp(File.join(path_item, "mappers/HighEfficiencyCreateBar.rb"), File.join(dir_name, "mappers"))

                # copy osw file
                FileUtils.cp(File.join(path_item, "mappers/createbar_workflow.osw"), File.join(dir_name, "mappers"))

              end

            elsif @opthash.subopts[:floorspace] == true

              # copy the mappers
              FileUtils.cp(File.join(path_item, "mappers/Floorspace.rb"), File.join(dir_name, "mappers"))
              FileUtils.cp(File.join(path_item, "mappers/HighEfficiencyFloorspace.rb"), File.join(dir_name, "mappers"))

              # copy osw file
              FileUtils.cp(File.join(path_item, "mappers/floorspace_workflow.osw"), File.join(dir_name, "mappers"))

              # copy feature file
              FileUtils.cp(File.join(path_item, "example_floorspace_project.json"), dir_name)

              # copy osm
              FileUtils.cp(File.join(path_item, "osm_building/7_floorspace.json"), File.join(dir_name, "osm_building"))
              FileUtils.cp(File.join(path_item, "osm_building/7_floorspace.osm"), File.join(dir_name, "osm_building"))
              FileUtils.cp(File.join(path_item, "osm_building/8.osm"), File.join(dir_name, "osm_building"))
              FileUtils.cp(File.join(path_item, "osm_building/9.osm"), File.join(dir_name, "osm_building"))
            end

            if @opthash.subopts[:residential]
              # copy residential files
              FileUtils.cp_r(File.join(path_item, "residential"), File.join(dir_name, "mappers", "residential"))
              FileUtils.cp_r(File.join(path_item, "measures"), File.join(dir_name, "measures"))
              FileUtils.cp_r(File.join(path_item, "resources"), File.join(dir_name, "resources"))
              FileUtils.cp(File.join(path_item, "example_project_combined.json"), dir_name)
            end

          elsif empty_folder == true
            Dir.mkdir dir_name
            FileUtils.cp(File.join(path_item, "Gemfile"), File.join(dir_name, "Gemfile"))
            FileUtils.cp_r(File.join(path_item, "mappers"), File.join(dir_name, "mappers"))
            FileUtils.cp_r(File.join(path_item, "visualization"), File.join(dir_name, "visualization"))

            if @opthash.subopts[:residential]
              # copy residential files
              FileUtils.cp_r(File.join(path_item, "residential"), File.join(dir_name, "mappers", "residential"))
              FileUtils.cp_r(File.join(path_item, "measures"), File.join(dir_name, "measures"))
              FileUtils.cp_r(File.join(path_item, "resources"), File.join(dir_name, "resources"))
              FileUtils.cp(File.join(path_item, "example_project_combined.json"), dir_name)
            end
          end
        end
      }

    end

    # Check Python
    # params\
    #
    # Check that sys has python 3.7+ installed
    def self.check_python
      results = { python: false, message: '' }
      puts 'Checking system.....'

      # platform agnostic
      stdout, stderr, status = Open3.capture3('python -V')
      if stderr && !stderr == ''
        # error
        results[:message] = "ERROR: #{stderr}"
        puts results[:message]
        return results
      end

      # check version
      stdout.slice! 'Python '
      if stdout[0].to_i == 2 || (stdout[0].to_i == 3 && stdout[2].to_i < 7)
        # global python version is not 3.7+
        results[:message] = "ERROR: Python version must be at least 3.7.  Found python with version #{stdout}."
        puts results[:message]
        return results
      else
        puts "...Python >= 3.7 found (#{stdout.chomp})"
      end

      # check pip
      stdout, stderr, status = Open3.capture3('pip -V')
      if stderr && !stderr == ''
        # error
        results[:message] = "ERROR finding pip: #{stderr}"
        puts results[:message]
        return results
      else
        puts '...pip found'
      end

      # all good
      puts 'System check done.'
      results[:python] = true
      return results
    end

    def self.check_reader
      results = { reader: false, message: '' }

      puts 'Checking for UrbanoptDittoReader...'

      stdout, stderr, status = Open3.capture3('pip list')
      if stderr && !stderr == ''
        # error
        results[:message] = 'ERROR running pip list'
        puts results[:message]
        return results
      end

      res = /^UrbanoptDittoReader.*$/.match(stdout)
      if res
        # extract version
        version = /\d+.\d+.\d+/.match(res.to_s)
        path = res.to_s.split(' ')[-1]
        puts "...path: #{path}"
        if version
          results[:message] = "Found UrbanoptDittoReader version #{version}"
          puts "...#{results[:message]}"
          results[:reader] = true
          puts "UrbanoptDittoReader check done. \n\n"
          return results
        else
          results[:message] = 'UrbanoptDittoReader version not found.'
          return results
        end
      else
        # no ditto reader
        results[:message] = 'UrbanoptDittoReader not found.'
        return results
      end
    end

    # Perform CLI actions

    # Create new project folder
    if @opthash.command == 'create' && @opthash.subopts[:project_folder] && @opthash.subopts[:empty] == false
      if @opthash.subopts[:overwrite] == true
        puts "\nOverwriting existing project folder: #{@opthash.subopts[:project_folder]}...\n\n"
        create_project_folder(@opthash.subopts[:project_folder], empty_folder = false, overwrite_project = true)
      elsif @opthash.subopts[:overwrite] == false
        puts "\nCreating a new project folder...\n"
        create_project_folder(@opthash.subopts[:project_folder], empty_folder = false, overwrite_project = false)
        if @opthash.subopts[:floorspace] == false && @opthash.subopts[:create_bar] == true
          puts "\nAn example FeatureFile is included: 'example_project.json'. You may place your own FeatureFile alongside the example."
        elsif @opthash.subopts[:floorspace] == true && @opthash.subopts[:create_bar] == false
          puts "\nAn example FeatureFile is included: 'example_floorspace_project.json'. You may place your own FeatureFile alongside the example."
        end
          puts 'Weather data is provided for the example FeatureFile. Additional weather data files may be downloaded from energyplus.net/weather for free'
          puts "If you use additional weather files, ensure they are added to the 'weather' directory. You will need to configure your mapper file and your osw file to use the desired weather file"
          puts "We recommend using absolute paths for all commands, for cleaner output\n"
      end
    elsif @opthash.command == 'create' && @opthash.subopts[:project_folder] && @opthash.subopts[:empty] == true
      if @opthash.subopts[:overwrite] == true
        puts "\nOverwriting existing project folder: #{@opthash.subopts[:project_folder]} with an empty folder...\n\n"
        create_project_folder(@opthash.subopts[:project_folder], empty_folder = true, overwrite_project = true)
      elsif @opthash.subopts[:overwrite] == false
        puts "\nCreating a new empty project folder...\n"
        create_project_folder(@opthash.subopts[:project_folder], empty_folder = true, overwrite_project = false)
      end
      puts "\nAdd your FeatureFile in the Project directory you just created."
      puts 'Add your weather data files in the Weather folder. They may be downloaded from energyplus.net/weather for free'
      puts 'Add your OpenStudio models for Features in your Feature file, if any in the osm_building folder'
      puts "We recommend using absolute paths for all commands, for cleaner output\n"
    end

    # Create ScenarioFile from FeatureFile
    if @opthash.command == 'create' && @opthash.subopts[:scenario_file]
      if @opthash.subopts[:single_feature]
        puts "\nBuilding sample ScenarioFiles, assigning mapper classes to Feature ID #{@opthash.subopts[:single_feature]}"
        create_scenario_csv_file(@opthash.subopts[:single_feature])
        puts "\nDone\n"
      else
        puts "\nBuilding sample ScenarioFiles, assigning mapper classes to each feature from #{@feature_name}"
        # Skip Feature ID argument if not present
        create_scenario_csv_file('SKIP')
        puts "\nDone\n"
      end
    end

    # Create REopt ScenarioFile from existing
    if @opthash.command == 'create' && @opthash.subopts[:reopt_scenario_file]
      puts "\nCreating ScenarioFile with REopt functionality, extending from #{@opthash.subopts[:reopt_scenario_file]}..."
      create_reopt_scenario_file(@opthash.subopts[:reopt_scenario_file])
      puts "\nDone"
    end

    # Run simulations
    if @opthash.command == 'run' && @opthash.subopts[:scenario] && @opthash.subopts[:feature]
      if @opthash.subopts[:scenario].to_s.include? '-'
        @scenario_folder = @scenario_file_name.split(/\W+/)[0].capitalize.to_s
        @feature_id = (@feature_name.split(/\W+/)[1]).to_s
      else
        @scenario_folder = @scenario_file_name.split('.')[0].capitalize.to_s
      end
      puts "\nSimulating features of '#{@feature_name}' as directed by '#{@scenario_file_name}'...\n\n"
      scenario_runner = URBANopt::Scenario::ScenarioRunnerOSW.new
      scenario_runner.run(run_func)
      puts "\nDone\n"
    end

    if @opthash.command == 'opendss'

      # first check python
      res = check_python
      if res[:python] == false
        puts "\nPython error: #{res[:message]}"
        abort("\nYou must install Python 3.7 or above and pip to use this workflow \n")
      end

      # then check if ditto_reader is installed
      res = check_reader
      if res[:reader] == false
        puts "\nURBANopt ditto reader error: #{res[:message]}"
        abort("\nYou must install urbanopt-ditto-reader to use this workflow: https://github.com/urbanopt/urbanopt-ditto-reader \n")
      end

      name = File.basename(@scenario_file_name, File.extname(@scenario_file_name))
      run_dir = File.join(@root_dir, 'run', name.downcase)
      featurefile = File.join(@root_dir, @feature_name)

      # Ensure building simulations have been run already
      begin
        feature_list = Pathname.new(run_dir).children.select(&:directory?)
        first_feature = File.basename(feature_list[0])
        if not File.exist?(File.join(run_dir, first_feature, 'eplusout.sql'))
          abort("\nERROR: URBANopt simulations are required before using opendss. Please run and process simulations, then try again.\n")
        end
      rescue Errno::ENOENT  # Same abort message if there is no run_dir
        abort("\nERROR: URBANopt simulations are required before using opendss. Please run and process simulations, then try again.\n")
      end

      # TODO: make this work for virtualenv
      # TODO: document adding PYTHON env var

      # create config hash
      config = {}

      config['use_reopt'] = @opthash.subopts[:reopt] == true
      config['urbanopt_scenario'] = run_dir
      config['geojson_file'] = featurefile
      if @opthash.subopts[:equipment]
        config['equipment_file'] = @opthash.subopts[:equipment].to_s
      end
      config['opendss_folder'] = File.join(config['urbanopt_scenario'], 'opendss')

      # TODO: allow users to specify ditto install location?
      # Currently using ditto within the urbanopt-ditto-reader install

      # run ditto_reader
      pyfrom 'urbanopt_ditto_reader', import: 'UrbanoptDittoReader'

      begin
        pconf = PyCall::Dict.new(config)
        r = UrbanoptDittoReader.new(pconf)
        r.run
      rescue StandardError => e
        abort("\nOpenDSS run did not complete successfully: #{e.message}")
      end

      puts "\nDone. Results located in #{config['opendss_folder']}\n"

    end

    # Post-process the scenario
    if @opthash.command == 'process'
      if @opthash.subopts[:default] == false && @opthash.subopts[:opendss] == false && @opthash.subopts[:reopt_scenario] == false && @opthash.subopts[:reopt_feature] == false
        abort("\nERROR: No valid process type entered. Must enter a valid process type\n")
      end

      puts 'Post-processing URBANopt results'

      # delete process_status.json
      process_filename = File.join(@root_dir, 'run', @scenario_file_name.split('.')[0].downcase, 'process_status.json')
      FileUtils.rm_rf(process_filename) if File.exist?(process_filename)
      results = []

      @scenario_folder = @scenario_file_name.split('.')[0].capitalize.to_s
      default_post_processor = URBANopt::Scenario::ScenarioDefaultPostProcessor.new(run_func)
      scenario_report = default_post_processor.run
      scenario_report.save
      scenario_report.feature_reports.each(&:save_feature_report)
      default_post_processor.create_scenario_db_file
      if @opthash.subopts[:default] == true
        puts "\nDone\n"
        results << {"process_type": "default", "status": "Complete", "timestamp": Time.now().strftime("%Y-%m-%dT%k:%M:%S.%L")}
      elsif @opthash.subopts[:opendss] == true
        puts "\nPost-processing OpenDSS results\n"
        opendss_folder = File.join(@root_dir, 'run', @scenario_file_name.split('.')[0], 'opendss')
        if File.directory?(opendss_folder)
          opendss_folder_name = File.basename(opendss_folder)
          opendss_post_processor = URBANopt::Scenario::OpenDSSPostProcessor.new(scenario_report, opendss_results_dir_name = opendss_folder_name)
          opendss_post_processor.run
          puts "\nDone\n"
          results << {"process_type": "opendss", "status": "Complete", "timestamp": Time.now().strftime("%Y-%m-%dT%k:%M:%S.%L")}
        else
          results << {"process_type": "opendss", "status": "failed", "timestamp": Time.now().strftime("%Y-%m-%dT%k:%M:%S.%L")}
          abort("\nNo OpenDSS results available in folder '#{opendss_folder}'\n")
        end
      elsif @opthash.subopts[:reopt_scenario] == true or @opthash.subopts[:reopt_feature] == true
        scenario_base = default_post_processor.scenario_base
        reopt_post_processor = URBANopt::REopt::REoptPostProcessor.new(scenario_report, scenario_base.scenario_reopt_assumptions_file, scenario_base.reopt_feature_assumptions, DEVELOPER_NREL_KEY)
        if @opthash.subopts[:reopt_scenario] == true
          puts "\nPost-processing entire scenario with REopt\n"
          scenario_report_scenario = reopt_post_processor.run_scenario_report(scenario_report: scenario_report, save_name: 'scenario_optimization')
          results << {"process_type": "reopt_scenario", "status": "Complete", "timestamp": Time.now().strftime("%Y-%m-%dT%k:%M:%S.%L")}
          puts "\nDone\n"
        elsif @opthash.subopts[:reopt_feature] == true
          puts "\nPost-processing each building individually with REopt\n"
          scenario_report_features = reopt_post_processor.run_scenario_report_features(scenario_report: scenario_report, save_names_feature_reports: ['feature_optimization'] * scenario_report.feature_reports.length, save_name_scenario_report: 'feature_optimization')
          results << {"process_type": "reopt_feature", "status": "Complete", "timestamp": Time.now().strftime("%Y-%m-%dT%k:%M:%S.%L")}
          puts "\nDone\n"
        end
      end

      # write process status file
      File.open(process_filename, "w") { |f| f.write JSON.pretty_generate(results) }

    end

    if @opthash.command == 'visualize'
      if @opthash.subopts[:scenarios] == false && @opthash.subopts[:features] == false
        abort("\nERROR: No valid process type entered. Must enter a valid process type\n")
      end

      if @opthash.subopts[:scenarios]
        @feature_path = File.split(File.absolute_path(@opthash.subopts[:scenarios]))[0]
        run_dir = File.join(@feature_path, 'run')
        scenario_folders = []
        scenario_report_exists = false
        Dir.glob(File.join(run_dir, '/*_scenario')) do |scenario_folder|
          scenario_report = File.join(scenario_folder, 'default_scenario_report.csv')
          if File.exist?(scenario_report)
            scenario_folders << scenario_folder
            scenario_report_exists = true
          else
            puts "\nERROR: Default reports not created for #{scenario_folder}. Please use 'process --default' to create default post processing reports for all scenarios first. Visualization not generated for #{scenario_folder}.\n"
          end
        end
        if scenario_report_exists == true
          puts "\nCreating visualizations for all Scenario results\n"
          URBANopt::Scenario::ResultVisualization.create_visualization(scenario_folders, false)
          vis_file_path = File.join(@feature_path, 'visualization')
          if !File.exists?(vis_file_path)
            Dir.mkdir File.join(@feature_path, 'visualization')
          end
          html_in_path = File.join(vis_file_path, 'input_visualization_scenario.html')
          if !File.exists?(html_in_path)
            visualization_file = 'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/visualization/input_visualization_scenario.html'
            vis_file_name = File.basename(visualization_file)
            vis_download = open(visualization_file, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
            IO.copy_stream(vis_download, File.join(vis_file_path, vis_file_name))
          end
          html_out_path = File.join(@feature_path, '/run/scenario_comparison.html')
          FileUtils.cp(html_in_path, html_out_path)
          puts "\nDone\n"
        end

      elsif @opthash.subopts[:features]
        @root_dir, @scenario_file_name = File.split(File.absolute_path(@opthash.subopts[:features]))
        name = File.basename(@scenario_file_name, File.extname(@scenario_file_name))
        run_dir = File.join(@root_dir, 'run', name.downcase)
        feature_report_exists = false
        feature_id = CSV.read(File.absolute_path(@opthash.subopts[:features]), :headers => true)
        feature_folders = []
        # loop through building feature ids from scenario csv
        feature_id["Feature Id"].each do |feature|
          feature_report = File.join(run_dir, feature, 'feature_reports')
          if File.exist?(feature_report)
            feature_report_exists = true
            feature_folders << File.join(run_dir, feature)
          else
            puts "\nERROR: Default reports not created for #{feature}. Please use 'process --default' to create default post processing reports for all features first. Visualization not generated for #{feature}.\n"
          end
        end
        if feature_report_exists == true
          puts "\nCreating visualizations for Feature results in the Scenario\n"
          URBANopt::Scenario::ResultVisualization.create_visualization(feature_folders, true)
          vis_file_path = File.join(@root_dir, 'visualization')
          if !File.exists?(vis_file_path)
            Dir.mkdir File.join(@root_dir, 'visualization')
          end
          html_in_path = File.join(vis_file_path, 'input_visualization_feature.html')
          if !File.exists?(html_in_path)
            visualization_file = 'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/visualization/input_visualization_feature.html'
            vis_file_name = File.basename(visualization_file)
            vis_download = open(visualization_file, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
            IO.copy_stream(vis_download, File.join(vis_file_path, vis_file_name))
          end
          html_out_path = File.join(@root_dir, 'run', name, 'feature_comparison.html')
          FileUtils.cp(html_in_path, html_out_path)
          puts "\nDone\n"
        end
      end

    end

    # Delete simulations from a scenario
    if @opthash.command == 'delete'
      scenario_name = @scenario_file_name.split('.')[0]
      scenario_path = File.absolute_path(@root_dir)
      scenario_results_dir = File.join(scenario_path, 'run', scenario_name)
      puts "\nDeleting previous results from '#{@scenario_file_name}'...\n"
      FileUtils.rm_rf(scenario_results_dir)
      puts "\nDone\n"
    end
  end
end
