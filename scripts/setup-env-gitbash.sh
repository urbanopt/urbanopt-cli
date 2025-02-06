#!/bin/bash
# This is a simple setup script that generates an environment file that
# is used to setup the ruby environment to run the urbanopt-cli tool.
# To use, just run this script in bash (e.g. ./setup-env.sh)
# Then you can use this env.sh to setup the environment.
# (e.g. source ~/.env_uo.sh)

RUBY_BASE_VERSION="3.2.0" 
MINICONDA_VERSION="4.12.0" 

BASE_DIR_NAME=$(dirname `which $0`)
UO_DIR_NAME=$(basename "$BASE_DIR_NAME")

GEM_HOME=${BASE_DIR_NAME}/gems/ruby/${RUBY_BASE_VERSION}
GEM_PATH=${BASE_DIR_NAME}/gems/ruby/${RUBY_BASE_VERSION}
PATH=${BASE_DIR_NAME}/ruby/bin:${BASE_DIR_NAME}/gems/ruby/${RUBY_BASE_VERSION}/bin:${BASE_DIR_NAME}/gems/ruby/${RUBY_BASE_VERSION}/gems/${UO_DIR_NAME}/example_files/python_deps/Miniconda-${MINICONDA_VERSION}/bin:$PATH
RUBYLIB=${BASE_DIR_NAME}/OpenStudio/Ruby
RUBY_DLL_PATH=${BASE_DIR_NAME}/OpenStudio/Ruby

#Remove if exists
if [ -f ~/.env_uo.sh ]; then
  rm ~/.env_uo.sh
fi

echo "export GEM_HOME=\"${GEM_HOME}\"" >> ~/.env_uo.sh
echo "export GEM_PATH=\"${GEM_PATH}\"" >> ~/.env_uo.sh
echo "export PATH=\"${PATH}\"" >> ~/.env_uo.sh
echo "export RUBYLIB=\"${RUBYLIB}\"" >> ~/.env_uo.sh
echo "export RUBY_DLL_PATH=\"${RUBY_DLL_PATH}\"" >> ~/.env_uo.sh
