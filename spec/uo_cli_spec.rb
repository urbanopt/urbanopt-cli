RSpec.describe URBANopt::CLI do
  it "has a version number" do
    expect(URBANopt::CLI::VERSION).not_to be nil
  end

  it "returns help" do
    expect { system %(ruby lib/uo_cli.rb -h) }
     .to output(a_string_including("Usage: uo"))
     .to_stdout_from_any_process
  end
end
