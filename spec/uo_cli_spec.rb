RSpec.describe URBANopt::CLI do

  # FIXME: "warning: class variable access from toplevel" at every instance of this @@variable
  @@test_directory = "spec/test_directory"
  
  # Ensure clean slate for testing
  # +dir_or_file+ string - path to a file or folder
  def delete_directory_or_file(dir_or_file)
    if File.exists?(dir_or_file)
      FileUtils.rm_rf(dir_or_file)
    end
  end
  
  context "Admin" do
    it 'has a version number' do
      expect(URBANopt::CLI::VERSION).not_to be nil
    end

    it 'returns help' do
      expect { system("ruby lib/uo_cli.rb -h") }
        .to output(a_string_including('Usage: uo'))
        .to_stdout_from_any_process
    end
  end

  context "Create project" do
    before :each do
      delete_directory_or_file(@@test_directory)
    end

    it 'creates an example project directory' do
      system("ruby lib/uo_cli.rb -p #{@@test_directory}")
      expect(File.exists?(File.join(@@test_directory, "example_project.json"))).to be true
    end

    it 'creates an empty project directory' do
      system("ruby lib/uo_cli.rb -e -p #{@@test_directory}")
      expect(File.exists?(File.join(@@test_directory, "example_project.json"))).to be false
      expect(File.exists?(File.join(@@test_directory, "mappers", "Baseline.rb"))).to be true
    end

    it 'does not overwrite a project directory without -o' do
      system("ruby lib/uo_cli.rb -p #{@@test_directory}")
      expect(File.exists?(File.join(@@test_directory, "example_project.json"))).to be true
      # FIXME: Test failure says nothing is written to stdout, but it is. Compare with line 20
      expect { system("ruby lib/uo_cli.rb -p #{@@test_directory}") }
        .to output(a_string_including('already a directory here'))
        .to_stdout_from_any_process
    end

    it "overwrites a project directory with -o" do
      system("ruby lib/uo_cli.rb -p #{@@test_directory}")
      expect(File.exists?(File.join(@@test_directory, "example_project.json"))).to be true
      # FIXME: Test failure says nothing is written to stdout, but it is. Compare with line 20
      expect { system("ruby lib/uo_cli.rb -o -p #{@test_directory}") }
        .to output(a_string_including("Overwriting"))
        .to_stdout
      expect(File.exists?(File.join(@@test_directory, "example_project.json"))).to be true
    end

    it "overwrites an existing project directory with an empty directory" do
      system("ruby lib/uo_cli.rb -p #{@@test_directory}")
      expect(File.exists?(File.join(@@test_directory, "example_project.json"))).to be true
      system("ruby lib/uo_cli.rb -e -o -p #{@@test_directory}")
      expect(File.exists?(File.join(@@test_directory, "example_project.json"))).to be false
      expect(File.exists?(File.join(@@test_directory, "mappers", "Baseline.rb"))).to be true
    end
  end

  context "Work with a small scenario" do
    before :all do
      delete_directory_or_file(@@test_directory)
      system("ruby lib/uo_cli.rb -p #{@@test_directory}")
    end

    it "creates a scenario file from a feature file" do
      expect(File.exists?(File.join(@@test_directory, "baseline_scenario.csv"))).to be false
      system("ruby lib/uo_cli.rb -m -f #{File.join(@@test_directory, "example_project.json")}")
      expect(File.exists?(File.join(@@test_directory, "baseline_scenario.csv"))).to be true
    end
    
    it "runs a 2 building scenario" do
      # Copy in a scenario file with only the first 2 buildings in it
      # TODO: Create the scenario file & edit it, so we don't need to maintain another copy that can get outdated
      system("cp spec/spec_files/two_building_scenario.csv #{@@test_directory}/two_building_scenario.csv")
      system("ruby lib/uo_cli.rb -r -s #{@@test_directory}/two_building_scenario.csv -f #{@@test_directory}/example_project.json")
      expect(File.exists?(File.join(@@test_directory, "run", "two_building_scenario", "1", "finished.job"))).to be true
      expect(File.exists?(File.join(@@test_directory, "run", "two_building_scenario", "2", "finished.job"))).to be true
      expect(File.exists?(File.join(@@test_directory, "run", "two_building_scenario", "3", "finished.job"))).to be false
    end

    it "post-processes a scenario" do
      system("ruby lib/uo_cli.rb -g -t default -s #{@@test_directory}/two_building_scenario.csv -f #{@@test_directory}/example_project.json")
      expect(File.exists?(File.join(@@test_directory, "run", "two_building_scenario", "default_scenario_report.csv"))).to be true
    end

    # it "reopt post-processes for a whole scenario" do
    #   system("ruby lib/uo_cli.rb -g -t reopt-scenario -s #{@@test_directory}/two_building_scenario.csv -f #{@@test_directory}/example_project.json")
    # expect(File.exists?(File.join(@@test_directory, "run", "two_building_scenario", "reopt", "blah"))).to be true
    # end

    # it "reopt post-processes each feature" do
    #   system("ruby lib/uo_cli.rb -g -t reopt-feature -s #{@@test_directory}/two_building_scenario.csv -f #{@@test_directory}/example_project.json")
    # expect(File.exists?(File.join(@@test_directory, "run", "two_building_scenario", "1", "blah"))).to be true
    # end
  end
end
