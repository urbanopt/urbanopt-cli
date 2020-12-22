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

RSpec.describe URBANopt::CLI do
  test_directory = File.join('spec', 'test_directory')
  test_directory_res = File.join('spec', 'test_directory_res')
  test_scenario = File.join(test_directory, 'two_building_scenario.csv')
  test_scenario_res = File.join(test_directory_res, 'two_building_res.csv')
  test_reopt_scenario = File.join(test_directory, 'REopt_scenario.csv')
  test_feature = File.join(test_directory, 'example_project.json')
  test_feature_res = File.join(test_directory_res, 'example_project_combined.json')
  call_cli = "ruby #{File.join('lib', 'uo_cli.rb')}"

  # Ensure clean slate for testing
  # +dir_or_file+ string - path to a file or folder
  def delete_directory_or_file(dir_or_file)
    if File.exist?(dir_or_file)
      FileUtils.rm_rf(dir_or_file)
    end
  end

  context 'Admin' do
    it 'displays the correct version number' do
      expect { system("#{call_cli} --version") }
        .to output(a_string_including(URBANopt::CLI::VERSION))
        .to_stdout_from_any_process
    end

    it 'returns help' do
      expect { system("#{call_cli} --help") }
        .to output(a_string_including('Commands:'))
        .to_stdout_from_any_process
    end

    it 'returns help for a specific command' do
      expect { system("#{call_cli} create --help") }
        .to output(a_string_including('Create project directory'))
        .to_stdout_from_any_process
    end
  end

  context 'Create project' do
    before :each do
      delete_directory_or_file(test_directory)
    end

    it 'creates an example project directory' do
      system("#{call_cli} create --project-folder #{test_directory}")
      expect(File.exist?(test_feature)).to be true
      expect(File.exist?(File.join(test_directory, 'mappers/Baseline.rb'))).to be true
    end

    it 'creates an example project directory when create bar geometry method specified' do
      system("#{call_cli} create --project-folder #{test_directory} --create-bar")
      expect(File.exist?(File.join(test_directory, 'mappers/CreateBar.rb'))).to be true
      expect(File.exist?(File.join(test_directory, 'mappers/createbar_workflow.osw'))).to be true
    end

    it 'creates an example project directory when floorspace method specified' do
      system("#{call_cli} create --project-folder #{test_directory} --floorspace")
      expect(File.exist?(File.join(test_directory, 'mappers/Floorspace.rb'))).to be true
      expect(File.exist?(File.join(test_directory, 'example_floorspace_project.json'))).to be true
    end

    it 'creates an example project directory for combined residential and commercial workflow' do
      system("#{call_cli} create --project-folder #{test_directory} --combined")
      expect(File.exist?(File.join(test_directory, 'mappers/residential'))).to be true
      expect(File.exist?(File.join(test_directory, 'example_project_combined.json'))).to be true
      expect(File.exist?(File.join(test_directory, 'measures'))).to be true
      expect(File.exist?(File.join(test_directory, 'resources'))).to be true
    end

    it 'creates an empty project directory' do
      system("#{call_cli} create --empty --project-folder #{test_directory}")
      expect(File.exist?(test_feature)).to be false
      expect(File.exist?(File.join(test_directory, 'mappers', 'Baseline.rb'))).to be true
    end

    it 'does not overwrite a project directory without --overwrite' do
      system("#{call_cli} create --project-folder #{test_directory}")
      expect(File.exist?(test_feature)).to be true
      expect { system("#{call_cli} create --project-folder #{test_directory}") }
        .to output(a_string_including('already a directory here'))
        .to_stderr_from_any_process
    end

    it 'overwrites a project directory with --overwrite' do
      system("#{call_cli} create --project-folder #{test_directory}")
      expect(File.exist?(test_feature)).to be true
      expect { system("#{call_cli} create --overwrite --project-folder #{test_directory}") }
        .to output(a_string_including('Overwriting'))
        .to_stdout_from_any_process
      expect(File.exist?(test_feature)).to be true
    end

    it 'overwrites an existing project directory with an empty directory' do
      system("#{call_cli} create --project-folder #{test_directory}")
      expect(File.exist?(test_feature)).to be true
      system("#{call_cli} create --empty --overwrite --project-folder #{test_directory}")
      expect(File.exist?(test_feature)).to be false
      expect(File.exist?(File.join(test_directory, 'mappers', 'Baseline.rb'))).to be true
    end
  end

  context 'Make and manipulate ScenarioFiles' do
    before :all do
      delete_directory_or_file(test_directory)
      system("#{call_cli} create --project-folder #{test_directory}")
    end

    it 'creates a scenario file from a feature file' do
      expect(File.exist?(File.join(test_directory, 'baseline_scenario.csv'))).to be false
      system("#{call_cli} create --scenario-file #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'baseline_scenario.csv'))).to be true
    end

    it 'creates a scenario file for a single feature from a feature file' do
      expect(File.exist?(File.join(test_directory, 'baseline_scenario-2.csv'))).to be false
      system("#{call_cli} create --scenario-file #{test_feature} --single-feature 2")
      expect(File.exist?(File.join(test_directory, 'baseline_scenario-2.csv'))).to be true
    end

    it 'creates a REopt ScenarioFile from an existing ScenarioFile and creates Reopt folder in project directory' do
      system("cp #{File.join('spec', 'spec_files', 'two_building_scenario.csv')} #{test_scenario}")
      expect(File.exist?(test_reopt_scenario)).to be false
      expect(File.exist?(File.join(test_directory, 'reopt'))).to be false
      system("#{call_cli} create --reopt-scenario-file #{test_scenario}")
      expect(File.exist?(test_reopt_scenario)).to be true
      expect(File.exist?(File.join(test_directory, 'reopt/base_assumptions.json'))).to be true
    end
  end

  context 'Run and work with a small simulation' do
    before :all do
      delete_directory_or_file(test_directory)
      system("#{call_cli} create --project-folder #{test_directory}")
    end

    it 'runs a 2 building scenario using default geometry method' do
      # Copy in a scenario file with only the first 2 buildings in it
      system("cp #{File.join('spec', 'spec_files', 'two_building_scenario.csv')} #{test_scenario}")
      system("#{call_cli} run --scenario #{test_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'failed.job'))).to be false
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '3', 'finished.job'))).to be false
    end

    it 'runs a 2 building scenario with residential and commercial buildings' do
      system("#{call_cli} create --project-folder #{test_directory_res} --combined")
      system("cp #{File.join('spec', 'spec_files', 'two_building_res.csv')} #{test_scenario_res}")

      system("#{call_cli} run --scenario #{test_scenario_res} --feature #{test_feature_res}")
      expect(File.exist?(File.join(test_directory_res, 'run', 'two_building_res', '1', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory_res, 'run', 'two_building_res', '16', 'finished.job'))).to be true
    end

    it 'runs a 2 building scenario using create bar geometry method' do
      # Copy create bar mapper
      system("cp #{File.join('example_files', 'mappers', 'CreateBar.rb')} #{File.join(test_directory, 'mappers', 'CreateBar.rb')}")
      # Copy osw file
      system("cp #{File.join('example_files', 'mappers', 'createbar_workflow.osw')} #{File.join(test_directory, 'mappers', 'createbar_workflow.osw')}")
      # Copy scenario file with 2 buildings in it
      system("cp #{File.join('spec', 'spec_files', 'two_building_create_bar.csv')} #{File.join(test_directory, 'two_building_create_bar.csv')}")
      system("#{call_cli} run --scenario #{File.join(test_directory, 'two_building_create_bar.csv')} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_create_bar', '1', 'finished.job'))).to be true
    end

    it 'runs a 2 building scenario using floorspace geometry method' do
      # Copy floorspace mapper
      system("cp #{File.join('example_files', 'mappers', 'Floorspace.rb')} #{File.join(test_directory, 'mappers', 'Floorspace.rb')}")
      # Copy osw file
      system("cp #{File.join('example_files', 'mappers', 'floorspace_workflow.osw')} #{File.join(test_directory, 'mappers', 'floorspace_workflow.osw')}")
      # Copy seed model and floospace.js file
      system("cp #{File.join('example_files', 'osm_building', '7_floorspace.json')} #{File.join(test_directory, 'osm_building', '7_floorspace.json')}")
      system("cp #{File.join('example_files', 'osm_building', '7_floorspace.osm')} #{File.join(test_directory, 'osm_building', '7_floorspace.osm')}")
      # Copy feature file
      system("cp #{File.join('example_files', 'example_floorspace_project.json')} #{File.join(test_directory, 'example_floorspace_project.json')}")
      # Copy scenario file with 2 buildings in it
      system("cp #{File.join('spec', 'spec_files', 'two_building_floorspace.csv')} #{File.join(test_directory, 'two_building_floorspace.csv')}")
      system("#{call_cli} run --scenario #{File.join(test_directory, 'two_building_floorspace.csv')} --feature #{File.join('../example_files/example_floorspace_project.json')}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_floorspace', '1', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_floorspace', '7', 'finished.job'))).to be true
    end

    it 'runs a scenario when called with reopt' do
      # Copy in a scenario file with only the first 2 buildings in it
      system("cp #{File.join('spec', 'spec_files', 'REopt_scenario.csv')} #{test_reopt_scenario}")
      # Copy in reopt folder
      system("cp -R #{File.join('spec', 'spec_files', 'reopt')} #{File.join(test_directory, 'reopt')}")
      system("#{call_cli} run --reopt --scenario #{test_reopt_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'reopt_scenario', '1', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'reopt_scenario', '2', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'reopt_scenario', '3', 'finished.job'))).to be false
    end

    it 'checks for python from opendss command' do
      # for now just check that it does the system check
      expect { system("#{call_cli} opendss --scenario #{test_scenario} --feature #{test_feature}") }
        .to output(a_string_including('Checking system.....'))
        .to_stdout_from_any_process
    end

    it 'post-processor exits gracefully if given an invalid type' do
      # Type is totally random
      expect { system("#{call_cli} process --foobar --scenario #{test_scenario} --feature #{test_feature}") }
        .to output(a_string_including("unknown argument '--foobar'"))
        .to_stderr_from_any_process
      # Type is valid, but with extra characters
      expect { system("#{call_cli} process --reopt-scenariot --scenario #{test_scenario} --feature #{test_feature}") }
        .to output(a_string_including("unknown argument '--reopt-scenariot'"))
        .to_stderr_from_any_process
      # Type would be valid if not missing characters
      expect { system("#{call_cli} process --reopt-scenari --scenario #{test_scenario} --feature #{test_feature}") }
        .to output(a_string_including("unknown argument '--reopt-scenari'"))
        .to_stderr_from_any_process
    end

    it 'post-processor exits gracefully if not given a type' do
      expect { system("#{call_cli} process --scenario #{test_scenario} --feature #{test_feature}") }
        .to output(a_string_including('No valid process type entered'))
        .to_stderr_from_any_process
    end

    it 'post-processes a scenario' do
      filename = File.join(test_directory, 'run', 'two_building_scenario', 'default_scenario_report.csv')
      system("#{call_cli} process --default --scenario #{test_scenario} --feature #{test_feature}")
      filename = File.join(test_directory, 'run', 'two_building_scenario', 'default_scenario_report.csv')
      expect(`wc -l < #{filename}`.to_i).to be > 2
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'process_status.json'))).to be true
    end

    it 'saves post-process output as a database file' do
      filename = File.join(test_directory, 'run', 'two_building_scenario', 'default_scenario_report.csv')
      db_filename = File.join(test_directory, 'run', 'two_building_scenario', 'default_scenario_report.db')
      system("#{call_cli} process --default --with-database --scenario #{test_scenario} --feature #{test_feature}")
      expect(`wc -l < #{db_filename}`.to_i).to be > 20
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'process_status.json'))).to be true
    end

    it 'reopt post-processes a scenario' do
      system("#{call_cli} process --reopt-scenario --scenario #{test_reopt_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'reopt_scenario', 'scenario_optimization.json'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'reopt_scenario', 'process_status.json'))).to be true
    end

    it 'reopt post-processes each feature' do
      system("#{call_cli} process --reopt-feature --scenario #{test_reopt_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'reopt_scenario', 'feature_optimization.csv'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'reopt_scenario', 'process_status.json'))).to be true
    end

    it 'opendss post-processes a scenario' do
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'opendss'))).to be false
      system("cp -R #{File.join('spec', 'spec_files', 'opendss')} #{File.join(test_directory, 'run', 'two_building_scenario', 'opendss')}")
      system("#{call_cli} process --opendss --scenario #{test_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'feature_reports', 'default_feature_report_opendss.csv'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'process_status.json'))).to be true
    end

    it 'creates scenario visualization for default post processor' do
      system("#{call_cli} process --default --scenario #{test_scenario} --feature #{test_feature}")
      system("#{call_cli} visualize --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'scenario_comparison.html'))).to be true
    end

    it 'creates feature visualization for default post processor' do
      system("#{call_cli} process --default --scenario #{test_scenario} --feature #{test_feature}")
      system("#{call_cli} visualize --scenario #{test_scenario}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'feature_comparison.html'))).to be true
    end

    it 'ensures viz files are in the project directory' do
      if File.exist?(File.join(test_directory, 'visualization', 'input_visualization_feature.html'))
        FileUtils.rm_rf(File.join(test_directory, 'visualization', 'input_visualization_feature.html'))
      end
      if File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'feature_comparison.html'))
        FileUtils.rm_rf(File.join(test_directory, 'run', 'two_building_scenario', 'feature_comparison.html'))
      end
      if File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'scenarioData.js'))
        FileUtils.rm_rf(File.join(test_directory, 'run', 'two_building_scenario', 'scenarioData.js'))
      end
      expect(File.exist?(File.join(test_directory, 'visualization', 'input_visualization_feature.html'))).to be false
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'feature_comparison.html'))).to be false
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'scenarioData.js'))).to be false
      system("#{call_cli} visualize --scenario #{test_scenario}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'feature_comparison.html'))).to be true
    end

    it 'deletes a scenario' do
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_create_bar', '1', 'data_point_out.json'))).to be true
      bar_scenario = File.join(test_directory, "two_building_create_bar.csv")
      system("#{call_cli} delete --scenario #{bar_scenario}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_create_bar', '1', 'data_point_out.json'))).to be false
    end
  end
end
