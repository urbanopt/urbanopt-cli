#!/bin/bash
# This is a simple setup script that generates an environment file that
# is used to setup the ruby environment to run the urbanopt-cli tool.
# To use, just run this script in bash (e.g. ./setup-env.sh)
# Then you can use this env.sh to setup the environment.
# (e.g. . env.sh)

UO_DIR=$(dirname "$(realpath "$0")")
UO_DIR_NAME=$(basename "$UO_DIR")

GEM_HOME=${UO_DIR}/gems/ruby/2.7.0
GEM_PATH=${UO_DIR}/gems/ruby/2.7.0
PATH=${UO_DIR}/ruby/bin:${UO_DIR}/gems/ruby/2.7.0/bin:${UO_DIR}/gems/ruby/2.7.0/gems/${UO_DIR_NAME}/example_files/python_deps/Miniconda-4.12.0/bin:$PATH
RUBYLIB=${UO_DIR}/OpenStudio/Ruby
RUBY_DLL_PATH=${UO_DIR}/OpenStudio/Ruby

# Remove if exists
if [ -f ~/.env_uo.sh ]; then
  rm ~/.env_uo.sh
fi

echo "export GEM_HOME=\"${GEM_HOME}\"" >> ~/.env_uo.sh
echo "export GEM_PATH=\"${GEM_PATH}\"" >> ~/.env_uo.sh
echo "export PATH=\"${PATH}\"" >> ~/.env_uo.sh
echo "export RUBYLIB=\"${RUBYLIB}\"" >> ~/.env_uo.sh
echo "export RUBY_DLL_PATH=\"${RUBY_DLL_PATH}\"" >> ~/.env_uo.sh
