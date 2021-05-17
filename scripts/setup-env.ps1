# This is a simple setup script that generates an enviroment file that 
# is used to setup the ruby enviroment to run the urbanopt-cli tool. 
# To use just run this script in powershell (e.g. ./setup-env.ps1) 
# Then you can use this env.ps1 to setup the enviroment. 
# (e.g. . env.ps1) 

if (-not (Test-Path $HOME)) { echo "env HOME needs to be set before running this script" }
if (-not (Test-Path $HOME)) { exit }

$BASE_DIR_NAME = $PSScriptRoot

$env:GEM_HOME      = "$BASE_DIR_NAME\gems\ruby\2.7.0"
$env:GEM_PATH      = "$BASE_DIR_NAME\gems\ruby\2.7.0"
$env:PATH         += ";$BASE_DIR_NAME\ruby\bin;$BASE_DIR_NAME\gems\ruby\2.7.0\bin"
$env:RUBYLIB       = "$BASE_DIR_NAME\OpenStudio\Ruby"
$env:RUBY_DLL_PATH = "$BASE_DIR_NAME\OpenStudio\Ruby"

# Remove if exists
Remove-Item $HOME/.env_uo.ps1 -ErrorAction Ignore

'$env:GEM_HOME       = "' + $env:GEM_HOME + '"'   >> $HOME/.env_uo.ps1
'$env:GEM_PATH       = "' + $env:GEM_PATH + '"'   >> $HOME/.env_uo.ps1
'$env:PATH           = "' + $env:PATH     + '"'   >> $HOME/.env_uo.ps1
'$env:RUBYLIB        = "' + $env:RUBYLIB  + '"'   >> $HOME/.env_uo.ps1
'$env:RUBY_DLL_PATH  = "' + $env:RUBY_DLL_PATH  + '"'   >> $HOME/.env_uo.ps1

