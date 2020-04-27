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
require 'optparse'
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
    # Set up user interface
    @user_input = {}
    the_parser = OptionParser.new do |opts|
      opts.banner = "\nUsage: uo [-peomrgdsfitv]\n" \
                    "\n" \
                    "URBANopt CLI\n" \
                    "First create a project folder with -p, then run additional commands as desired\n" \
                    "Additional config options can be set with the 'runner.conf' file inside your new project folder"
      opts.separator ''

      opts.on('-p', '--project_folder <DIR>', String, "Create project directory named <DIR> in your current folder\n" \
          "                                     Fewer warnings are presented when using full paths and the user is not inside the project folder\n\n") do |folder|
        @user_input[:project_folder] = folder
      end

      opts.on('-e', '--empty_project_folder', String, "Use with -p argument to create an empty project folder\n" \
          "                                     Example: uo -e -p <DIR>\n" \
          "                                     Then add your own Feature file in the project directory you created,\n" \
          "                                     add Weather files in the weather folder and add OpenStudio models of Features\n" \
          "                                     in the Feature File, if any, in the osm_building folder\n" \
          "                                     Fewer warnings are presented when using full paths and the user is not inside the project folder\n\n") do
        @user_input[:empty_project_folder] = 'Create empty project folder' # This text does not get displayed to the user
      end

      opts.on('-o', '--overwrite_project_folder', String, "Use with -p argument to overwrite existing project folder and replace with new project folder.\n" \
          "                                     Or use with -e and -p argument to overwrite existing project folder and replace with new empty project folder.\n" \
          "                                     Usage: uo -o -p <DIR>\n" \
          "                                     or uo -o -e -p <DIR>\n" \
          "                                     Where <DIR> is the existing project folder\n\n") do
        @user_input[:overwrite_project_folder] = 'Overwriting existing project folder' # This text does not get displayed to the user
      end

      opts.on('-m', '--make_scenario', String, "Create ScenarioCSV files for each MapperFile using the Feature file path. Must specify -f argument\n" \
          "                                     Example: uo -m -f example_project.json\n" \
          "                                     Or, Create Scenario CSV for each MapperFile for a single Feature from Feature File. Must specify -f and -i argument\n" \
          "                                     Example: uo -m -f example_project.json -i 1\n\n") do
        @user_input[:make_scenario_from] = "Create scenario files from FeatureFiles or for single Feature according to the MapperFiles in the 'mappers' directory" # This text does not get displayed to the user
      end

      opts.on('-r', '--run', String, "Run simulations. Must specify -s & -f arguments\n" \
          "                                     Example: uo -r -s baseline_scenario.csv -f example_project.json\n\n") do
        @user_input[:run_scenario] = 'Run simulations' # This text does not get displayed to the user
      end

      opts.on('-g', '--gather', String, "group individual feature results to scenario-level results. Must specify -t, -s, & -f arguments\n" \
          "                                     Example: uo -g -t default -s baseline_scenario.csv -f example_project.json\n\n") do
        @user_input[:gather] = 'Aggregate all features to a whole Scenario' # This text does not get displayed to the user
      end

      opts.on('-d', '--delete_scenario', String, "Delete results from scenario. Must specify -s argument\n" \
          "                                     Example: uo -d -s baseline_scenario.csv\n\n") do
        @user_input[:delete_scenario] = 'Delete scenario results that were created from <SFP>' # This text does not get displayed to the user
      end

      opts.on('-s', '--scenario_file <SFP>', String, "Specify <SFP> (ScenarioCSV file path). Used as input for other commands\n\n") do |scenario|
        @user_input[:scenario] = scenario
        @root_dir, @scenario_file_name = File.split(File.absolute_path(@user_input[:scenario]))
      end

      opts.on('-f', '--feature_file <FFP>', String, "Specify <FFP> (Feature file path). Used as input for other commands\n\n") do |feature|
        @user_input[:feature] = feature
        @feature_path, @feature_name = File.split(File.absolute_path(@user_input[:feature]))
      end

      opts.on('-i', '--feature_id <FID>', Integer, "Specify <FID> (Feature ID). Used as input for other commands\n\n") do |feature_id|
        @user_input[:feature_id] = feature_id
      end

      opts.on('-t', '--type <TYPE>', String, "Specify <TYPE> of post-processor to run:\n" \
          "                                       default\n" \
          "                                       reopt-scenario\n" \
          "                                       reopt-feature\n" \
          "                                       opendss\n\n") do |type|
        @user_input[:type] = type
      end

      opts.on('-v', '--version', "Show CLI version and exit\n") do
        @user_input[:version_request] = VERSION
      end
    end

    begin
      the_parser.parse!
    rescue OptionParser::InvalidOption => e
      puts e
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
      scenario_output = URBANopt::Scenario::REoptScenarioCSV.new(name, @root_dir, run_dir, feature_file, mapper_files_dir, csv_file, num_header_rows, reopt_files_dir, reopt_assumptions_filename)
      scenario_output
    end

    # Create a scenario csv file from a FeatureFile
    # params\
    # +feature_file_path+:: _string_ Path to a FeatureFile
    def self.create_scenario_csv_file(feature_id)
      feature_file_json = JSON.parse(File.read(File.absolute_path(@user_input[:feature])), symbolize_names: true)
      Dir["#{@feature_path}/mappers/*.rb"].each do |mapper_file|
        mapper_name = File.basename(mapper_file, File.extname(mapper_file))
        scenario_file_name = if feature_id == 'SKIP'
                               "#{mapper_name.downcase}_scenario.csv"
                             else
                               "#{mapper_name.downcase}_scenario-#{feature_id}.csv"
                             end
        CSV.open(File.join(@feature_path, scenario_file_name), 'wb', write_headers: true,
                                                                     headers: ['Feature Id', 'Feature Name', 'Mapper Class', 'REopt Assumptions']) do |csv|
          feature_file_json[:features].each do |feature|
            if feature_id == 'SKIP'
              # ensure that feature is a building
              if feature[:properties][:type] == 'Building'
                csv << [feature[:properties][:id], feature[:properties][:name], "URBANopt::Scenario::#{mapper_name}Mapper", 'multiPV_assumptions.json']
              end
            elsif feature_id == feature[:properties][:id].to_i
              csv << [feature[:properties][:id], feature[:properties][:name], "URBANopt::Scenario::#{mapper_name}Mapper", 'multiPV_assumptions.json']
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

    # Create project folder
    # params\
    # +dir_name+:: _string_ Name of new project folder
    #
    # Folder gets created in the current working directory
    # Includes weather for UO's example location, a base workflow file, and mapper files to show a baseline and a high-efficiency option.
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
      # Dir.mkdir File.join(dir_name, 'measures') # FIXME: When residential hpxml flow is implemented
      # Dir.mkdir File.join(dir_name, 'resources') # FIXME: When residential hpxml flow is implemented
      Dir.mkdir File.join(dir_name, 'weather')
      Dir.mkdir File.join(dir_name, 'reopt')
      Dir.mkdir File.join(dir_name, 'osm_building')
      mappers_dir_abs_path = File.absolute_path(File.join(dir_name, 'mappers/'))
      # measures_dir_abs_path = File.absolute_path(File.join(dir_name, 'measures/')) # FIXME: When residential hpxml flow is implemented
      # resources_dir_abs_path = File.absolute_path(File.join(dir_name, 'resources/')) # FIXME: When residential hpxml flow is implemented
      weather_dir_abs_path = File.absolute_path(File.join(dir_name, 'weather/'))
      reopt_dir_abs_path = File.absolute_path(File.join(dir_name, 'reopt/'))
      osm_dir_abs_path = File.absolute_path(File.join(dir_name, 'osm_building/'))

      config_file = 'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/runner.conf'
      example_feature_file = 'https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/example_project.json'
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

      # FIXME: When residential hpxml flow is implemented
      remote_measures_files = [
      ]

      # FIXME: When residential hpxml flow is implemented
      remote_resources_files = [
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
    if @user_input[:project_folder] && @user_input[:empty_project_folder].nil?
      if @user_input[:overwrite_project_folder]
        puts "\nOverwriting existing project folder: #{@user_input[:project_folder]}...\n\n"
        puts "Creating a new project folder...\n"
        create_project_folder(@user_input[:project_folder], empty_folder = false, overwrite_project = true)
      elsif @user_input[:overwrite_project_folder].nil?
        create_project_folder(@user_input[:project_folder], empty_folder = false, overwrite_project = false)
      end
      puts "\nAn example FeatureFile is included: 'example_project.json'. You may place your own FeatureFile alongside the example."
      puts 'Weather data is provided for the example FeatureFile. Additional weather data files may be downloaded from energyplus.net/weather for free'
      puts "If you use additional weather files, ensure they are added to the 'weather' directory. You will need to configure your mapper file and your osw file to use the desired weather file"
      puts "Next, create ScenarioFiles using this CLI call: 'uo -m -f <FFP>'\n"
      puts "We recommend using absolute paths for all commands, for cleaner output\n"
    elsif @user_input[:project_folder] && @user_input[:empty_project_folder]
      if @user_input[:overwrite_project_folder]
        puts "\nOverwriting existing project folder: #{@user_input[:project_folder]}...\n\n"
        puts "Creating a new project folder...\n\n"
        create_project_folder(@user_input[:project_folder], empty_folder = true, overwrite_project = true)
      elsif @user_input[:overwrite_project].nil?
        create_project_folder(@user_input[:project_folder], empty_folder = true, overwrite_project = false)
      end
      puts 'Add your FeatureFile in the Project directory you just created.'
      puts 'Add your weather data files in the Weather folder. They may be downloaded from energyplus.net/weather for free'
      puts 'Add your OpenStudio models for Features in your Feature file, if any in the osm_building folder'
      puts "Next, create ScenarioFiles using this CLI call: 'uo -m -f <FFP>'\n"
      puts "We recommend using absolute paths for all commands, for cleaner output\n"
    end

    if @user_input[:make_scenario_from]
      if @user_input[:feature].nil?
        abort("\nYou must provide the '-f' flag and a valid path to a FeatureFile!\n---\n\n")
      end

      if @user_input[:feature_id]
        puts "\nBuilding sample ScenarioFiles, assigning mapper classes to Feature ID #{@user_input[:feature_id]}..."
        create_scenario_csv_file(@user_input[:feature_id])
        puts "\nDone\n"
      else
        puts "\nBuilding sample ScenarioFiles, assigning mapper classes to each feature from #{@feature_name}..."
        # Skip Feature ID argument if not present
        create_scenario_csv_file('SKIP')
        puts "\nDone\n"
      end
    end

    if @user_input[:run_scenario]
      if @user_input[:scenario].nil?
        abort("\nYou must provide '-s' flag and a valid path to a ScenarioFile!\n---\n\n")
      end
      if @user_input[:feature].nil?
        abort("\nYou must provide '-f' flag and a valid path to a FeatureFile!\n---\n\n")
      end
      if @user_input[:scenario].to_s.include? '-'
        @scenario_folder = @scenario_file_name.split(/\W+/)[0].capitalize.to_s
        @feature_id = (@feature_name.split(/\W+/)[1]).to_s
      else
        @scenario_folder = @scenario_file_name.split('.')[0].capitalize.to_s
      end
      puts "\nSimulating features of '#{@feature_name}' as directed by '#{@user_input[:scenario]}'...\n\n"
      scenario_runner = URBANopt::Scenario::ScenarioRunnerOSW.new
      scenario_runner.run(run_func)
      puts "\nDone\n"
    end

    if @user_input[:gather]
      if @user_input[:scenario].nil?
        abort("\nYou must provide '-s' flag and a valid path to a ScenarioFile!\n---\n\n")
      end
      if @user_input[:feature].nil?
        abort("\nYou must provide '-f' flag and a valid path to a FeatureFile!\n---\n\n")
      end

      valid_postprocessors = ['default', 'reopt-scenario', 'reopt-feature', 'opendss']
      # Abort if <type> is nil or not in valid list
      if @user_input[:type].nil? || valid_postprocessors.none? { |needle| @user_input[:type].include? needle }
        abort("\nYou must provide '-t' flag and a valid Gather type!\n" \
            "Valid types include: #{valid_postprocessors}\n---\n\n")
      end

      @scenario_folder = @scenario_file_name.split('.')[0].capitalize.to_s

      default_post_processor = URBANopt::Scenario::ScenarioDefaultPostProcessor.new(run_func)
      scenario_report = default_post_processor.run
      scenario_report.save
      # FIXME: Remove this feature_reports block once urbanopt/urbanopt-scenario-gem#104 works as expected.
      # save feature reports
      scenario_report.feature_reports.each(&:save_feature_report)

      if @user_input[:type] == valid_postprocessors[0]
        puts "\nDone\n"
      elsif @user_input[:type] == valid_postprocessors[3]
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
      elsif @user_input[:type].to_s.include?('reopt')
        scenario_base = default_post_processor.scenario_base
        reopt_post_processor = URBANopt::REopt::REoptPostProcessor.new(scenario_report, scenario_base.scenario_reopt_assumptions_file, scenario_base.reopt_feature_assumptions, DEVELOPER_NREL_KEY)

        # Optimize REopt outputs for the whole Scenario
        if @user_input[:type] == valid_postprocessors[1]
          puts "\nOptimizing renewable energy for the scenario\n"
          scenario_report_scenario = reopt_post_processor.run_scenario_report(scenario_report: scenario_report, save_name: 'scenario_optimization')
          puts "\nDone\n"
        # Optimize REopt outputs for each feature individually
        elsif @user_input[:type] == valid_postprocessors[2]
          puts "\nOptimizing renewable energy for each feature\n"
          scenario_report_features = reopt_post_processor.run_scenario_report_features(scenario_report: scenario_report, save_names_feature_reports: ['feature_optimization'] * scenario_report.feature_reports.length, save_name_scenario_report: 'feature_optimization')
          puts "\nDone\n"
        end
      else
        abort("\nError: did not use one of these valid types: #{valid_postprocessors} Aborting...\n---\n\n")
      end
    end

    if @user_input[:delete_scenario]
      if @user_input[:scenario].nil?
        abort("\nYou must provide '-s' flag and a valid path to a ScenarioFile!\n---\n\n")
      end
      scenario_name = @scenario_file_name.split('.')[0]
      scenario_path = File.absolute_path(@root_dir)
      scenario_results_dir = File.join(scenario_path, 'run', scenario_name)
      puts "\nDeleting previous results from '#{@scenario_file_name}'...\n"
      FileUtils.rm_rf(scenario_results_dir)
      puts "\nDone\n"
    end

    if @user_input[:version_request]
      puts "\nURBANopt CLI version: #{@user_input[:version_request]}\n---\n\n"
    end
  end
end
