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
      expect { system("#{call_cli} -v") }
        .to output(a_string_including(URBANopt::CLI::VERSION))
        .to_stdout_from_any_process
    end

    it 'returns help' do
      expect { system("#{call_cli} -h") }
        .to output(a_string_including('Usage: uo'))
        .to_stdout_from_any_process
    end

    it 'deletes a scenario' do
      delete_directory_or_file(test_directory)
      system("cp -R #{File.join('spec', 'spec_files', 'test_directory')} #{test_directory}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'data_point_out.json'))).to be true
      system("#{call_cli} -d -s #{test_scenario}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'data_point_out.json'))).to be false
    end
  end

  context 'Create project' do
    before :each do
      delete_directory_or_file(test_directory)
    end

    it 'creates an example project directory' do
      system("#{call_cli} -p #{test_directory}")
      expect(File.exist?(test_feature)).to be true
    end

    it 'creates an empty project directory' do
      system("#{call_cli} -e -p #{test_directory}")
      expect(File.exist?(test_feature)).to be false
      expect(File.exist?(File.join(test_directory, 'mappers', 'Baseline.rb'))).to be true
    end

    it 'does not overwrite a project directory without -o' do
      system("#{call_cli} -p #{test_directory}")
      expect(File.exist?(test_feature)).to be true
      expect { system("#{call_cli} -p #{test_directory}") }
        .to output(a_string_including('already a directory here'))
        .to_stderr_from_any_process
    end

    it 'overwrites a project directory with -o' do
      system("#{call_cli} -p #{test_directory}")
      expect(File.exist?(test_feature)).to be true
      expect { system("#{call_cli} -o -p #{test_directory}") }
        .to output(a_string_including('Overwriting'))
        .to_stdout_from_any_process
      expect(File.exist?(test_feature)).to be true
    end

    it 'overwrites an existing project directory with an empty directory' do
      system("#{call_cli} -p #{test_directory}")
      expect(File.exist?(test_feature)).to be true
      system("#{call_cli} -e -o -p #{test_directory}")
      expect(File.exist?(test_feature)).to be false
      expect(File.exist?(File.join(test_directory, 'mappers', 'Baseline.rb'))).to be true
    end
  end

  context 'Prepare and run a small simulation' do
    before :all do
      delete_directory_or_file(test_directory)
      system("#{call_cli} -p #{test_directory}")
    end

    it 'creates a scenario file from a feature file' do
      expect(File.exist?(File.join(test_directory, 'baseline_scenario.csv'))).to be false
      system("#{call_cli} -m -f #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'baseline_scenario.csv'))).to be true
    end

    it 'creates a scenario file for a single feature from a feature file' do
      system("uo -m -f #{test_feature} -i 1")
      expect(File.exist?(File.join(test_directory, 'baseline_scenario-1.csv'))).to be true
    end

    it 'actually runs a 2 building scenario' do
      # Copy in a scenario file with only the first 2 buildings in it
      system("cp #{File.join('spec', 'spec_files', 'test_directory', 'two_building_scenario.csv')} #{test_scenario}")
      system("#{call_cli} -r -s #{test_scenario} -f #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '2', 'finished.job'))).to be true
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '3', 'finished.job'))).to be false
    end
  end

  context 'Post-process a scenario' do
    before :all do
      delete_directory_or_file(test_directory)
      system("cp -R #{File.join('spec', 'spec_files', 'test_directory')} #{test_directory}")
    end

    it 'post-processor exits gracefully if given an invalid type' do
      expect { system("#{call_cli} -g -t foobar -s #{test_scenario} -f #{test_feature}") }
        .to output(a_string_including('valid Gather type!'))
        .to_stderr_from_any_process
    end

    it 'post-processes a scenario' do
      system("#{call_cli} -g -t default -s #{test_scenario} -f #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'default_scenario_report.csv'))).to be true
    end

    it 'reopt post-processes a scenario' do
      system("#{call_cli} -g -t reopt-scenario -s #{test_scenario} -f #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', 'reopt', 'scenario_report_two_building_scenario_reopt_run.json'))).to be true
    end

    it 'reopt post-processes each feature' do
      system("#{call_cli} -g -t reopt-feature -s #{test_scenario} -f #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'reopt', 'feature_report_1_reopt_run.json'))).to be true
    end

    it 'opendss post-processes a scenario' do
      system("#{call_cli} -g -t opendss -s #{test_scenario} -f #{test_feature}")
      expect(File.exist?(File.join(test_directory, 'run', 'two_building_scenario', '1', 'feature_reports', 'default_feature_report_opendss.csv'))).to be true
    end
  end
end
