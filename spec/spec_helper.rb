# *********************************************************************************
# URBANopt (tm), Copyright (c) Alliance for Energy Innovation, LLC.
# See also https://github.com/urbanopt/urbanopt-cli/blob/develop/LICENSE.md
# *********************************************************************************

# require 'simplecov'
# require 'simplecov-lcov'

# SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
# SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
# # Don't consider the spec folder for test coverage reporting (inside the do/end loop)
# SimpleCov.start do
#   add_filter '/spec/'
# end

require 'bundler/setup'

RSpec.configure do |config|
  # Recording test status enables flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
