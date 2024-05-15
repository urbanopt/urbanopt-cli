#!/bin/bash
# This is a simple setup script that generates an enviroment file that
# is used to setup the ruby enviroment to run the urbanopt-cli tool.
# To use, just run this script in bash (e.g. ./setup-env.sh)
# Then you can use this env.sh to setup the enviroment.
# (e.g. source ~/.env_uo.sh)


BASE_DIR_NAME=$(dirname `which $0`)

GEM_HOME=${BASE_DIR_NAME}/gems/ruby/2.7.0
GEM_PATH=${BASE_DIR_NAME}/gems/ruby/2.7.0
PATH=${BASE_DIR_NAME}/ruby/bin:${BASE_DIR_NAME}/gems/ruby/2.7.0/bin:${BASE_DIR_NAME}/gems/ruby/2.7.0/gems/urbanopt-cli-0.11.1/example_files/python_deps/Miniconda-4.12.0/bin:$PATH
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
