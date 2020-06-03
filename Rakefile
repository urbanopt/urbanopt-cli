require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

# Load in the rake tasks from the base openstudio-extension gem
require 'openstudio/extension/rake_task'
os_extension = OpenStudio::Extension::RakeTask.new
os_extension.set_extension_class(OpenStudio::Extension::Extension, 'urbanopt/urbanopt-cli')

task default: :spec
