#!/usr/bin/ ruby

#*********************************************************************************
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
#*********************************************************************************

require "uo_cli/version"
require "optparse"
require "urbanopt/geojson"
require "urbanopt/scenario"
require "csv"
require "json"
require "openssl"


module URBANopt
  module CLI

    # Set up user interface
    @user_input = {}
    the_parser = OptionParser.new do |opts|
        opts.banner = "Usage: uo [-pemradsfiv]\n" +
        "\n" +
        "URBANopt CLI\n" +
        "First create a project folder with -p, then run additional commands as desired\n" +
        "Additional config options can be set with the 'runner.conf' file inside your new project folder"
        opts.separator ""

        opts.on("-p", "--project_folder <DIR>",String, "Create project directory named <DIR> in your current folder\n" +
            "                                     You must be inside the project directory you just created for all following commands to work") do |folder|
            @user_input[:project_folder] = folder
        end

        opts.on("-e", "--empty_project_folder", String, "Use with -p argument to create an empty project folder\n" +
            "                                     Example: uo -e -p <DIR>\n" +
            "                                     Then add your own Feature file in the project directory you created,\n" +
            "                                     add Weather files in the weather folder and add OpenStudio models of Features \n" +
            "                                     in the Feature File, if any in the osm_building folder \n" +
            "                                     You must be inside the project directory you just created for all following commands to work") do
            @user_input[:empty_project_folder] = "Create empty project folder"  # This text does not get displayed to the user
        end
        
        opts.on("-m", "--make_scenario", String, "Create ScenarioCSV files for each MapperFile using the Feature file path. Must specify -f argument\n" +
            "                                     Example: uo -m -f example_project.json\n" +
            "                                     Or, Create Scenario CSV for each MapperFile for a single Feature from Feature File. Must specify -f and -i argument\n" +
            "                                     Example: uo -m -f example_project.json -i 1") do
            @user_input[:make_scenario_from] = "Create scenario files from FeatureFiles or for single Feature according to the MapperFiles in the 'mappers' directory"  # This text does not get displayed to the user
        end
        
        opts.on("-r", "--run", String, "Run simulations. Must specify -s & -f arguments\n" +
            "                                     Example: uo -r -s baseline_scenario.csv -f example_project.json") do
            @user_input[:run_scenario] = "Run simulations"  # This text does not get displayed to the user
        end

        opts.on("-a", "--aggregate", String, "Aggregate individual feature results to scenario-level results. Must specify -s & -f arguments\n" +
            "                                     Example: uo -a -s baseline_scenario.csv -f example_project.json") do
            @user_input[:aggregate] = "Aggregate all features to a whole Scenario"  # This text does not get displayed to the user
        end
        
        opts.on("-d", "--delete_scenario", String, "Delete results from scenario. Must specify -s argument\n" +
            "                                     Example: uo -d -s baseline_scenario.csv") do
            @user_input[:delete_scenario] = "Delete scenario results that were created from <SFP>"  # This text does not get displayed to the user
        end
        
        opts.on("-s", "--scenario_file <SFP>", String, "Specify <SFP> (ScenarioCSV file path). Used as input for other commands") do |scenario|
            @user_input[:scenario] = scenario
        end
        
        opts.on("-f", "--feature_file <FFP>", String, "Specify <FFP> (Feature file path). Used as input for other commands") do |feature|
            @user_input[:feature] = feature
        end
        
        opts.on("-i", "--feature_id <FID>", Integer, "Specify <FID> (Feature ID). Used as input for other commands") do |feature_id|
            @user_input[:feature_id] = feature_id
        end
        
        opts.on("-v", "--version", "Show CLI version and exit") do
            @user_input[:version_request] = VERSION
        end
    end

    begin
        the_parser.parse!
    rescue OptionParser::InvalidOption => e
      puts e
    end

    # Simulate energy usage for each Feature or for single feature as defined by ScenarioCSV\
    # params\
    # +scenario+:: _string_ Path to csv file that defines the scenario\
    # +feature_file_path+:: _string_ Path to Feature File used to describe set of features in the district
    # 
    # FIXME: This only works when scenario_file and feature_file are in the project root directory
    # This works when called with filename (from inside project directory) and with absolute filepaths
    # Also, feels a little weird that now I'm only using instance variables and not passing anything to this function. I guess it's ok?
    def self.run_func 
        root_dir = File.dirname(File.absolute_path(@user_input[:scenario]))
        scenario_basename = File.basename(File.absolute_path(@user_input[:scenario]))
        name = File.basename(scenario_basename, File.extname(scenario_basename))
        run_dir = File.join(root_dir, 'run', name.downcase)

        if @feature_id
            feature_run_dir = File.join(run_dir,@feature_id)
            # If run folder for feature exists, remove it
            if File.exist?(feature_run_dir)
               FileUtils.rm_rf(feature_run_dir)
            end
        end

        csv_file = File.join(root_dir, scenario_basename)
        featurefile = File.join(root_dir, @feature_name)
        mapper_files_dir = File.join(root_dir, "mappers")
        num_header_rows = 1

        feature_file = URBANopt::GeoJSON::GeoFile.from_file(featurefile)
        scenario_output = URBANopt::Scenario::ScenarioCSV.new(name, root_dir, run_dir, feature_file, mapper_files_dir, csv_file, num_header_rows)
        return scenario_output
    end

    # Create a scenario csv file from a FeatureFile
    # params\
    # +feature_file_path+:: _string_ Path to a FeatureFile
    def self.create_scenario_csv_file(feature_file_path, feature_id)
        feature_file_json = JSON.parse(File.read(feature_file_path), :symbolize_names => true)
        Dir["#{@feature_path}/mappers/*.rb"].each do |mapper_file|
            mapper_path, mapper_name = File.split(mapper_file)
            mapper_name = mapper_name.split('.')[0]
            unless feature_id == 'SKIP'
                scenario_file_name = "#{mapper_name.downcase}_scenario-#{feature_id}.csv"
            else
                scenario_file_name = "#{mapper_name.downcase}_scenario.csv"
            end    
            CSV.open(File.join(@feature_path, scenario_file_name), "wb", :write_headers => true,
            :headers => ["Feature Id","Feature Name","Mapper Class"]) do |csv|
                feature_file_json[:features].each do |feature|
                    if feature_id == 'SKIP'
                        # ensure that feature is a building
                        if feature[:properties][:type] == "Building"
                            csv << [feature[:properties][:id], feature[:properties][:name], "URBANopt::Scenario::#{mapper_name}Mapper"]
                        end
                    elsif feature_id == feature[:properties][:id].to_i
                        csv << [feature[:properties][:id], feature[:properties][:name], "URBANopt::Scenario::#{mapper_name}Mapper"]
                    elsif
                        # If Feature ID specified does not exist in the Feature File raise error
                        unless feature_file_json[:features].any? {|hash| hash[:properties][:id].include?(feature_id.to_s)}
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
    def self.create_project_folder(dir_name, empty_folder = false)
        if Dir.exist?(dir_name)
            abort("ERROR:  there is already a directory here named #{dir_name}... aborting")
        else
            puts "CREATING URBANopt project directory: #{dir_name}"
            Dir.mkdir dir_name
            Dir.mkdir File.join(dir_name, 'mappers')
            Dir.mkdir File.join(dir_name, 'weather')
            Dir.mkdir File.join(dir_name, 'osm_building')
            mappers_dir_abs_path = File.absolute_path(File.join(dir_name, 'mappers/'))
            weather_dir_abs_path = File.absolute_path(File.join(dir_name, 'weather/'))
            osm_dir_abs_path = File.absolute_path(File.join(dir_name, 'osm_building/'))

            # FIXME: When residential hpxml flow is implemented
            # (https://github.com/urbanopt/urbanopt-example-geojson-project/pull/24 gets merged)
            # these files will change
            
            
            remote_mapper_files = [
                "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/mappers/base_workflow.osw",
                "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/mappers/Baseline.rb",
                "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/mappers/HighEfficiency.rb",
            ]
            
            example_gem_file = "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/Gemfile"
            
            # Download mapper files to user's local machine
            remote_mapper_files.each do |mapper_file|
                mapper_path, mapper_name = File.split(mapper_file)
                mapper_download = open(mapper_file, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
                IO.copy_stream(mapper_download, File.join(mappers_dir_abs_path, mapper_name))
            end

            # Download gemfile to user's local machine
            gem_path, gem_name = File.split(example_gem_file)
            example_gem_download = open(example_gem_file, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
            IO.copy_stream(example_gem_download, File.join(dir_name, gem_name))

            #if argument for creating an empty folder is not added
            if empty_folder == false
                
                example_feature_file = "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/example_project.json"
            
                remote_weather_files = [
                    "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/weather/USA_NY_Buffalo-Greater.Buffalo.Intl.AP.725280_TMY3.epw",
                    "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/weather/USA_NY_Buffalo-Greater.Buffalo.Intl.AP.725280_TMY3.ddy",
                    "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/weather/USA_NY_Buffalo-Greater.Buffalo.Intl.AP.725280_TMY3.stat",
                ]

                osm_files = [
                    "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/osm_building/7.osm",
                    "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/osm_building/8.osm",
                    "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/osm_building/9.osm"
                ]

                config_file = "https://raw.githubusercontent.com/urbanopt/urbanopt-cli/master/example_files/runner.conf"
                config_path, config_name = File.split(config_file)
                config_download = open(config_file, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
                IO.copy_stream(config_download, File.join(dir_name, config_name))

                
                # Download weather file to user's local machine
                remote_weather_files.each do |weather_file|
                    weather_path, weather_name = File.split(weather_file)
                    weather_download = open(weather_file, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
                    IO.copy_stream(weather_download, File.join(weather_dir_abs_path, weather_name))
                end

                osm_files.each do |osm_file|
                    osm_path, osm_name = File.split(osm_file)
                    osm_download = open(osm_file, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
                    IO.copy_stream(osm_download, File.join(osm_dir_abs_path, osm_name))
                end

                feature_path, feature_name = File.split(example_feature_file)
                example_feature_download = open(example_feature_file, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
                IO.copy_stream(example_feature_download, File.join(dir_name, feature_name))

            end
        end
    end


    # Perform CLI actions
    if @user_input[:project_folder] && @user_input[:empty_project_folder].nil?
        create_project_folder(@user_input[:project_folder], empty_folder = false)
        puts "\nAn example FeatureFile is included: 'example_project.json'. You may place your own FeatureFile alongside the example."
        puts "Weather data is provided for the example FeatureFile. Additional weather data files may be downloaded from energyplus.net/weather for free"
        puts "If you use additional weather files, ensure they are added to the 'weather' directory. You will need to configure your mapper file and your osw file to use the desired weather file"
        puts "Next, move inside your new folder ('cd <FolderYouJustCreated>') and create ScenarioFiles using this CLI call: 'uo -m -f <FFP>'"
    elsif @user_input[:project_folder] && @user_input[:empty_project_folder]
        create_project_folder(@user_input[:project_folder], empty_folder = true)
        puts "Add your FeatureFile in the Project directory you just created."
        puts "Add your weather data files in the Weather folder. They may be downloaded from energyplus.net/weather for free"
        puts "Add your OpenStudio models for Features in your Feature file, if any in the osm_building folder"
        puts "Next, move inside your new folder ('cd <FolderYouJustCreated>') and create ScenarioFiles using this CLI call: 'uo -m -f <FFP>'"
    end

    if @user_input[:make_scenario_from]
        if @user_input[:feature].nil?
            abort("\nYou must provide the '-f' flag and a valid path to a FeatureFile!\n---\n\n")
        end

        @feature_path, @feature_name = File.split(@user_input[:feature])
        if @user_input[:feature_id]
            puts "\nBuilding sample ScenarioFiles, assigning mapper classes to Feature ID #{@user_input[:feature_id]}..."
            create_scenario_csv_file(@user_input[:feature], @user_input[:feature_id])
            puts "Done"
        else    
            puts "\nBuilding sample ScenarioFiles, assigning mapper classes to each feature from #{@feature_name}..."
            # Skip Feature ID argument if not present
            create_scenario_csv_file(@user_input[:feature], 'SKIP')
            puts "Done"
        end
    end



    if @user_input[:run_scenario]
        if @user_input[:scenario].nil?
            abort("\nYou must provide '-s' flag and a valid path to a ScenarioFile!\n---\n\n")
        end
        if @user_input[:feature].nil?
            abort("\nYou must provide '-f' flag and a valid path to a FeatureFile!\n---\n\n")
        end
        if @user_input[:scenario].include? "-"
            @scenario_folder = "#{@user_input[:scenario].split(/\W+/)[0].capitalize}"
            @feature_id = "#{@user_input[:scenario].split(/\W+/)[1]}"
        else
            @scenario_folder = "#{@user_input[:scenario].split('.')[0].capitalize}"
        end
        @feature_path, @feature_name = File.split(@user_input[:feature])
        puts "\nSimulating features of '#{@feature_name}' as directed by '#{@user_input[:scenario]}'...\n\n"
        scenario_runner = URBANopt::Scenario::ScenarioRunnerOSW.new
        scenario_runner.run(run_func())
        puts "Done"
    end

    if @user_input[:aggregate]
        if @user_input[:scenario].nil?
            abort("\nYou must provide '-s' flag and a valid path to a ScenarioFile!\n---\n\n")
        end
        if @user_input[:feature].nil?
            abort("\nYou must provide '-f' flag and a valid path to a FeatureFile!\n---\n\n")
        end
        @scenario_folder = "#{@user_input[:scenario].split('.')[0].capitalize}"
        @scenario_path, @scenario_name = File.split(@user_input[:scenario])
        @feature_path, @feature_name = File.split(@user_input[:feature])
        
        puts "\nAggregating results across all features of #{@feature_name} according to '#{@scenario_name}'...\n"
        scenario_result = URBANopt::Scenario::ScenarioDefaultPostProcessor.new(run_func()).run
        scenario_result.save
        
        opendss_post_processor = URBANopt::Scenario::OpenDSSPostProcessor.new(scenario_result, 'opendss')
        opendss_post_processor.run
        puts "Done"
    end

    if @user_input[:delete_scenario]
        if @user_input[:scenario].nil?
            abort("\nYou must provide '-s' flag and a valid path to a ScenarioFile!\n---\n\n")
        end
        @scenario_path, @scenario_name = File.split(@user_input[:scenario])
        scenario_name = @scenario_name.split('.')[0]
        scenario_path = File.absolute_path(@scenario_path)
        scenario_results_dir = File.join(scenario_path, 'run', scenario_name)
        puts "\nDeleting previous results from '#{@scenario_name}'..."
        FileUtils.rm_rf(scenario_results_dir)
        puts "Done"
    end

    if @user_input[:version_request]
        puts "URBANopt CLI version: #{@user_input[:version_request]}"
    end

  end  # End module CLI

end  # End module Urbanopt
