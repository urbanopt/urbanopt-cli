#!/bin/bash 
BASE_DIR_NAME=$(dirname `which $0`)

GEM_HOME=${BASE_DIR_NAME}/urbanopt_cli_gems/ruby/2.5.0
GEM_PATH=${BASE_DIR_NAME}/urbanopt_cli_gems/ruby/2.5.0
PATH=${BASE_DIR_NAME}/ruby/bin:${BASE_DIR_NAME}/urbanopt_cli_gems/ruby/2.5.0/bin:$PATH
RUBYLIB=${BASE_DIR_NAME}/OpenStudio/Ruby

# Remove it exists
if [ -f .env ]; then
  rm .env
fi

echo "export GEM_HOME=\"${GEM_HOME}\"" >> .env
echo "export GEM_PATH=\"${GEM_PATH}\"" >> .env
echo "export PATH=\"${PATH}\"" >> .env
echo "export RUBYLIB=\"${RUBYLIB}\"" >> .env

source .env
