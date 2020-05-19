
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uo_cli/version'

Gem::Specification.new do |spec|
  spec.name            = 'urbanopt-cli'
  spec.version         = URBANopt::CLI::VERSION
  spec.authors         = ['Nathan Moore']
  spec.email           = ['nathan.moore@nrel.gov']

  spec.summary         = 'URBANopt CLI'
  spec.description     = 'Interfacing with URBANopt'
  spec.homepage        = 'https://docs.urbanopt.net/'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org/'
    spec.metadata['homepage_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'bin'
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables = ['uo']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.5.0'

  #   use specific versions of these dependencies while using Ruby 2.2
  #spec.add_development_dependency 'rack', '2.1.2'

  #   use specific versions of urbanopt and openstudio dependencies while under heavy development
  spec.add_dependency 'optimist'
  spec.add_dependency 'urbanopt-geojson', '0.3.0.pre1'
  spec.add_dependency 'urbanopt-reopt', '0.3.0.pre1'
  spec.add_dependency 'urbanopt-scenario', '0.3.0.pre1'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.54.0'
end
