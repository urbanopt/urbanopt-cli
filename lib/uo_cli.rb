#!/usr/bin/ ruby

# *********************************************************************************
# URBANopt, Copyright (c) 2019-2020, Alliance for Sustainable Energy, LLC, and other
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
require 'json'
require 'openssl'
require_relative '../developer_nrel_key'

module URBANopt
  module CLI
    class UrbanOptCLI
      COMMAND_MAP = {
        'create' => 'Make new things - project directory or files',
        'run' => 'Use files in your directory to simulate district energy use',
        'process' => 'Post-process URBANopt simulations for additional insights',
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
#        return if ARGV.empty?
        @command = "create" # Hard code an arg for testing purposes
        send("opt_#{@command}") ## dispatch to command handling method
      end

      # Define creation commands
      def opt_create
        cmd = @command
        @subopts = Optimist.options do
          banner "\nURBANopt #{cmd}:\n \n"

          opt :project_folder, "\nCreate project directory in your current folder. Name the directory\n" \
          'Example: uo create --project urbanopt_example_project', type: String

          opt :empty, "\nUse with --project-folder argument to create an empty project folder\n" \
          "Then add your own Feature file in the project directory you created,\n" \
          "add Weather files in the weather folder and add OpenStudio models of Features\n" \
          "in the Feature File, if any, in the osm_building folder\n" \
          "Example: uo create --empty --project-folder urbanopt_example_project\n" \

          opt :overwrite, "\nUse with --project-folder argument to overwrite existing project folder and replace with new project folder.\n" \
          "May be combined with --empty as well to overwrite existing project folder and replace with new empty project folder.\n" \
          'Example: uo create --overwrite --empty --project-folder urbanopt_project_folder_I_want_destroyed'

          opt :scenario_file, "\nAutomatically create a ScenarioFile containing the features in FeatureFile for each scenario\n" \
          "Provide the FeatureFile used to create the ScenarioFile\n" \
          'Example: uo create --scenario-file example_project.json', type: String

          opt :single_feature, "\nCreate a ScenarioFile with only a single feature\n" \
          "Use the FeatureID from your FeatureFile\n" \
          "Requires 'scenario-file' also be specified, to say which FeatureFile will create the ScenarioFile\n" \
          'Example: uo create --single-feature 2 --scenario-file example_project.json', type: String

          opt :reopt_scenario_file, "\nCreate a ScenarioFile that includes a column defining the REopt assumptions file\n" \
          "Specify the existing ScenarioFile that you want to extend with REopt functionality\n" \
          'Example: uo create --reopt-scenario-file baseline_scenario.csv', type: String
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
          'Example: uo run --scenario baseline_scenario-2.csv --feature example_project.jsonn', default: 'baseline_scenario.csv', required: true

          opt :feature, "\nRun URBANopt simulations according to <featurefile>\n" \
          "Requires --scenario also be specified\n" \
          'Example: uo run --scenario baseline_scenario.csv --feature example_project.json', default: 'example_project.json', required: true
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
    # params\
    # +scenario+:: _string_ Path to csv file that defines the scenario\
    # +feature_file_path+:: _string_ Path to Feature File used to describe set of features in the district
    def self.run_func
      name = File.basename(@scenario_file_name, File.extname(@scenario_file_name))
      run_dir = File.join(@root_dir, 'run', name.downcase)
      csv_file = File.join(@root_dir, @scenario_file_name)
      featurefile = File.join(@root_dir, @feature_name)
      mapper_files_dir = File.join(@root_dir, 'mappers')
      reopt_files_dir = File.join(@root_dir, 'reopt/')
      num_header_rows = 1
      # FIXME: This can be cleaned up in Ruby 2.5 with Dir.children(<"foldername">)
      # TODO: Better way of grabbing assumptions file than the first file in the folder
      reopt_files_dir_contents_list = Dir["#{reopt_files_dir}/*"]
      reopt_assumptions_filename = File.basename(reopt_files_dir_contents_list[0])

      if @feature_id
        feature_run_dir = File.join(run_dir, @feature_id)
        # If run folder for feature exists, remove it
        FileUtils.rm_rf(feature_run_dir) if File.exist?(feature_run_dir)
      end

      feature_file = URBANopt::GeoJSON::GeoFile.from_file(featurefile)
      if @opthash.subopts[:reopt] == true || @opthash.subopts[:reopt_scenario] == true || @opthash.subopts[:reopt_feature] == true
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
      Dir.mkdir dir_name
      Dir.mkdir File.join(dir_name, 'mappers')
      Dir.mkdir File.join(dir_name, 'weather')
      Dir.mkdir File.join(dir_name, 'reopt')
      Dir.mkdir File.join(dir_name, 'osm_building')
      mappers_dir_abs_path = File.absolute_path(File.join(dir_name, 'mappers/'))
      weather_dir_abs_path = File.absolute_path(File.join(dir_name, 'weather/'))
      reopt_dir_abs_path = File.absolute_path(File.join(dir_name, 'reopt/'))
      osm_dir_abs_path = File.absolute_path(File.join(dir_name, 'osm_building/'))

      config_file = 'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/runner.conf'
      example_feature_file = 'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/example_project.json'
      # FIXME: Gemfile is TEMPORARILY pointint to branch. Restore to master before merging to master.
      example_gem_file = 'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/Gemfile'
      remote_weather_files = [
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/weather/USA_NY_Buffalo-Greater.Buffalo.Intl.AP.725280_TMY3.epw',
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/weather/USA_NY_Buffalo-Greater.Buffalo.Intl.AP.725280_TMY3.ddy',
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/weather/USA_NY_Buffalo-Greater.Buffalo.Intl.AP.725280_TMY3.stat'
      ]
      osm_files = [
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/osm_building/7.osm',
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/osm_building/8.osm',
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/osm_building/9.osm'
      ]

      reopt_files = [
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/reopt/base_assumptions.json',
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/reopt/multiPV_assumptions.json'
      ]

      # FIXME: When residential hpxml flow is implemented
      # (https://github.com/urbanopt/urbanopt-example-geojson-project/pull/24 gets merged)
      # these files will change
      remote_mapper_files = [
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/mappers/base_workflow.osw',
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/mappers/Baseline.rb',
        'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/mappers/HighEfficiency.rb'
      ]

      # Download mapper files to user's local machine
      remote_mapper_files.each do |mapper_file|
        mapper_name = File.basename(mapper_file)
        mapper_download = open(mapper_file, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
        IO.copy_stream(mapper_download, File.join(mappers_dir_abs_path, mapper_name))
      end

      # Download gemfile to user's local machine
      gem_name = File.basename(example_gem_file)
      example_gem_download = open(example_gem_file, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      IO.copy_stream(example_gem_download, File.join(dir_name, gem_name))

      # if argument for creating an empty folder is not added
      if empty_folder == false

        # Download reopt files to user's local machine
        reopt_files.each do |reopt_remote_file|
          reopt_file = File.basename(reopt_remote_file)
          reopt_file_download = open(reopt_remote_file, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
          IO.copy_stream(reopt_file_download, File.join(reopt_dir_abs_path, reopt_file))
        end

        # Download config file to user's local machine
        config_name = File.basename(config_file)
        config_download = open(config_file, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
        IO.copy_stream(config_download, File.join(dir_name, config_name))

        # Download weather file to user's local machine
        remote_weather_files.each do |weather_file|
          weather_name = File.basename(weather_file)
          weather_download = open(weather_file, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
          IO.copy_stream(weather_download, File.join(weather_dir_abs_path, weather_name))
        end

        # Download osm files to user's local machine
        osm_files.each do |osm_file|
          osm_name = File.basename(osm_file)
          osm_download = open(osm_file, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
          IO.copy_stream(osm_download, File.join(osm_dir_abs_path, osm_name))
        end

        # Download feature file to user's local machine
        feature_name = File.basename(example_feature_file)
        example_feature_download = open(example_feature_file, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
        IO.copy_stream(example_feature_download, File.join(dir_name, feature_name))
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
      end
      puts "\nAn example FeatureFile is included: 'example_project.json'. You may place your own FeatureFile alongside the example."
      puts 'Weather data is provided for the example FeatureFile. Additional weather data files may be downloaded from energyplus.net/weather for free'
      puts "If you use additional weather files, ensure they are added to the 'weather' directory. You will need to configure your mapper file and your osw file to use the desired weather file"
      puts "We recommend using absolute paths for all commands, for cleaner output\n"
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

    # Post-process the scenario
    if @opthash.command == 'process'
      if @opthash.subopts[:default] == false && @opthash.subopts[:opendss] == false && @opthash.subopts[:reopt_scenario] == false && @opthash.subopts[:reopt_feature] == false
        abort("\nERROR: No valid process type entered. Must enter a valid process type\n")
      end
      @scenario_folder = @scenario_file_name.split('.')[0].capitalize.to_s
      default_post_processor = URBANopt::Scenario::ScenarioDefaultPostProcessor.new(run_func)
      scenario_report = default_post_processor.run
      scenario_report.save
      if @opthash.subopts[:default] == true
        puts 'Post-processing URBANopt results'
        puts "\nDone\n"
      elsif @opthash.subopts[:opendss] == true
        puts "\nPost-processing OpenDSS results\n"
        opendss_folder = File.join(@root_dir, 'run', @scenario_file_name.split('.')[0], 'opendss')
        if File.directory?(opendss_folder)
          opendss_folder_name = File.basename(opendss_folder)
          opendss_post_processor = URBANopt::Scenario::OpenDSSPostProcessor.new(scenario_report, opendss_results_dir_name = opendss_folder_name)
          opendss_post_processor.run
          puts "\nDone\n"
        else
          abort("\nNo OpenDSS results available in folder '#{opendss_folder}'\n")
        end
      elsif @opthash.subopts.to_s.include?('reopt')
        scenario_base = default_post_processor.scenario_base
        reopt_post_processor = URBANopt::REopt::REoptPostProcessor.new(scenario_report, scenario_base.scenario_reopt_assumptions_file, scenario_base.reopt_feature_assumptions, DEVELOPER_NREL_KEY)
        if @opthash.subopts[:reopt_scenario] == true
          puts "\nPost-processing entire scenario with REopt\n"
          scenario_report_scenario = reopt_post_processor.run_scenario_report(scenario_report: scenario_report, save_name: 'scenario_optimization')
          puts "\nDone\n"
        elsif @opthash.subopts[:reopt_feature] == true
          puts "\nPost-processing each building individually with REopt\n"
          scenario_report_features = reopt_post_processor.run_scenario_report_features(scenario_report: scenario_report, save_names_feature_reports: ['feature_optimization'] * scenario_report.feature_reports.length, save_name_scenario_report: 'feature_optimization')
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
