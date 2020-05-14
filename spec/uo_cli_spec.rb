RSpec.describe URBANopt::CLI do
  test_directory = File.join('spec', 'test_directory')
  test_scenario = File.join(test_directory, 'two_building_scenario.csv')
  test_feature = File.join(test_directory, 'example_project.json')
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

    it 'creates a REopt ScenarioFile from an existing ScenarioFile' do
      system("cp #{File.join('spec', 'spec_files', 'two_building_scenario.csv')} #{test_scenario}")
      expect(File.exist?(File.join(test_directory, 'REopt_scenario.csv'))).to be false
      system("#{call_cli} create --reopt-scenario-file #{test_scenario}")
      expect(File.exist?(File.join(test_directory, 'REopt_scenario.csv'))).to be true
    end
  end

  context 'Run and work with a small simulation' do
    before :all do
      delete_directory_or_file(test_directory)
      system("#{call_cli} create --project-folder #{test_directory}")
    end

    it 'actually runs a 2 building scenario' do
      # Copy in a scenario file with only the first 2 buildings in it
      system("cp #{File.join('spec', 'spec_files', 'two_building_scenario.csv')} #{test_scenario}")
      system("#{call_cli} run --scenario #{test_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '2', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '3', 'finished.job'))).to be false
    end

    it 'runs a scenario when called with reopt' do
      # Copy in a scenario file with only the first 2 buildings in it
      system("cp #{File.join('spec', 'spec_files', 'two_building_scenario.csv')} #{test_scenario}")
      system("#{call_cli} run --reopt --scenario #{test_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '2', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '3', 'finished.job'))).to be false
    end

    it 'post-processor exits gracefully if given an invalid type' do
      expect { system("#{call_cli} process --foobar --scenario #{test_scenario} --feature #{test_feature}") }
        .to output(a_string_including("unknown argument '--foobar'"))
        .to_stderr_from_any_process
      expect { system("#{call_cli} process --reopt-scenariot --scenario #{test_scenario} --feature #{test_feature}") }
        .to output(a_string_including("unknown argument '--reopt-scenariot'"))
        .to_stderr_from_any_process
    end

    it 'post-processor exits gracefully if not given a type' do
      expect { system("#{call_cli} process --scenario #{test_scenario} --feature #{test_feature}") }
        .to output(a_string_including('No valid process type entered'))
        .to_stderr_from_any_process
    end

    it 'post-processes a scenario' do
      system("#{call_cli} process --default --scenario #{test_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'default_scenario_report.csv'))).to be true
    end

    it 'reopt post-processes a scenario' do
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'scenario_optimization.json'))).to be false
      system("#{call_cli} process --reopt-scenario --scenario #{test_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'scenario_optimization.json'))).to be true
    end

    it 'reopt post-processes each feature' do
      system("#{call_cli} process --reopt-feature --scenario #{test_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'feature_reports', 'feature_optimization.csv'))).to be true
    end

    it 'opendss post-processes a scenario' do
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'opendss'))).to be false
      system("cp -R #{File.join('spec', 'spec_files', 'opendss')} #{File.join(test_directory, 'run', 'two_building_scenario', 'opendss')}")
      system("#{call_cli} process --opendss --scenario #{test_scenario} --feature #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'feature_reports', 'default_feature_report_opendss.csv'))).to be true
    end

    it 'deletes a scenario' do
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'data_point_out.json'))).to be true
      system("#{call_cli} delete --scenario #{test_scenario}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'data_point_out.json'))).to be false
    end
  end
end
