source 'http://rubygems.org'

# Specify dependencies in uo_cli.gemspec
gemspec

# Local gems are useful when developing and integrating the various dependencies.
# To favor the use of local gems, set the following environment variable:
#   Mac: export FAVOR_LOCAL_GEMS=1
#   Windows: set FAVOR_LOCAL_GEMS=1
# Note that if allow_local is true, but the gem is not found locally, then it will
# checkout the latest version (develop) from github.
allow_local = ENV['FAVOR_LOCAL_GEMS']

# Uncomment (and modify path/branch) if you need to test local development versions. Otherwise
# these are included in the gemspec file

# Delete this once testing is complete!
gem 'bcl', github: 'NREL/bcl-gem', branch: 'faraday'
#
# if allow_local && File.exist?('../OpenStudio-extension-gem')
#  gem 'openstudio-extension', path: '../OpenStudio-extension-gem'
# elsif allow_local
  gem 'openstudio-extension', github: 'NREL/OpenStudio-extension-gem', branch: 'faraday'
# end
# gem 'openstudio-extension', '0.9.0'

gem 'urbanopt-core', github: 'URBANopt/urbanopt-core-gem', branch: 'faraday'

# if allow_local && File.exist?('../urbanopt-scenario-gem')
#   gem 'urbanopt-scenario', path: '../urbanopt-scenario-gem'
# elsif allow_local
  gem 'urbanopt-scenario', github: 'URBANopt/urbanopt-scenario-gem', branch: 'faraday'
# end

# if allow_local && File.exist?('../urbanopt-geojson-gem')
#   gem 'urbanopt-geojson', path: '../urbanopt-geojson-gem'
# elsif allow_local
  gem 'urbanopt-geojson', github: 'URBANopt/urbanopt-geojson-gem', branch: 'faraday'
# end

# if allow_local && File.exist?('../urbanopt-reopt-gem')
#   gem 'urbanopt-reopt', path: '../urbanopt-reopt-gem'
# elsif allow_local
  gem 'urbanopt-reopt', github: 'URBANopt/urbanopt-reopt-gem', branch: 'faraday'
# end

# if allow_local && File.exist?('../urbanopt-reporting-gem')
#   gem 'urbanopt-reporting', path: '../urbanopt-reporting-gem'
# elsif allow_local
  gem 'urbanopt-reporting', github: 'URBANopt/urbanopt-reporting-gem', branch: 'faraday'
# end

# if allow_local && File.exist?('../urbanopt-rnm-us-gem')
#   gem 'urbanopt-rnm-us', path: '../urbanopt-rnm-us-gem'
# elsif allow_local
  gem 'urbanopt-rnm-us', github: 'URBANopt/urbanopt-rnm-us-gem', branch: 'faraday'
# end
