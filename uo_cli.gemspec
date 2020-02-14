
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "uo_cli/version"

Gem::Specification.new do |spec|
  spec.name            = "uo_cli"
  spec.version         = URBANopt::CLI::VERSION
  spec.authors         = ["Nathan Moore"]
  spec.email           = ["nathan.moore@nrel.gov"]

  spec.summary         = "URBANopt CLI"
  spec.description     = "Interfacing with URBANopt"
  spec.homepage        = "https://docs.urbanopt.net/"
#   spec.source_code_uri = "https://github.com/urbanopt/uo-cli"
#   spec.changelog_uri   = "https://github.com/urbanopt/uo-cli/blob/master/CHANGELOG.md"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
    spec.metadata["homepage_uri"] = spec.homepage
    # FIXME: These 2 metadata entries appear to cause an error when bundling. Make that not happen
    # spec.metadata["source_code_uri"] = spec.source_code_uri
    # spec.metadata["changelog_uri"] = spec.changelog_uri
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  # Specify which files should be added to the gem when it is released. 
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables  = ["uo"]
  spec.require_paths = ["lib"]

  spec.add_dependency "urbanopt-scenario", "~> 0.1.1"
  spec.add_dependency "urbanopt-geojson", "~> 0.1.0"
  
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "github_api", "~> 0.18.0"

#   Fix version while we are on Ruby 2.2.4
  spec.add_development_dependency "rack", "2.1.2"

end
