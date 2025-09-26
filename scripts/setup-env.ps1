# This is a simple setup script that generates an environment file that
# is used to setup the ruby environment to run the urbanopt-cli tool.
# To use just run this script in powershell (e.g. ./setup-env.ps1)
# Then you can use this env.ps1 to setup the environment.
# (e.g. . env.ps1)
 $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

if (-not (Test-Path $HOME)) { echo "env HOME needs to be set before running this script" }
if (-not (Test-Path $HOME)) { exit }


$RUBY_BASE_VERSION = "3.2.0" 
# uo install_python will install its own python within the gem directories so we need to find the python path and add it to $env.PATH
$output = Get-ChildItem -ErrorAction SilentlyContinue -Directory "C:\URBANopt*" -Recurse -Filter "python-3.10" | Select-Object FullName

if ($output.FullName) { 
  $RUBY_PYTHON_PATH = $output.FullName 
}
else {
  $RUBY_PYTHON_PATH = ""
}


$BASE_DIR_NAME = $PSScriptRoot

$GEM_HOME      = "$BASE_DIR_NAME\gems\ruby\$RUBY_BASE_VERSION"
$GEM_PATH      = "$BASE_DIR_NAME\gems\ruby\$RUBY_BASE_VERSION"
$UO_GEMFILE_PATH  = "$UO_DIR\gems\Gemfile"
$UO_BUNDLE_INSTALL_PATH  = "$UO_DIR\gems"
$PATH         += ";$BASE_DIR_NAME\ruby\bin;$BASE_DIR_NAME\gems\ruby\$RUBY_BASE_VERSION\bin;$RUBY_PYTHON_PATH;$env::PATH"
$RUBYLIB       = "$BASE_DIR_NAME\OpenStudio\Ruby"
$RUBY_DLL_PATH = "$BASE_DIR_NAME\OpenStudio\Ruby"

# Remove if exists
Remove-Item $HOME/.env_uo.ps1 -ErrorAction Ignore
Remove-Item $HOME/.env_uo.bat -ErrorAction Ignore

'$env:GEM_HOME       = "' + $GEM_HOME + '"'   >> $HOME/.env_uo.ps1
'$env:GEM_PATH       = "' + $GEM_PATH + '"'   >> $HOME/.env_uo.ps1
'$env:UO_GEMFILE_PATH   = "' + $UO_GEMFILE_PATH + '"'   >> $HOME/.env_uo.ps1
'$env:UO_BUNDLE_INSTALL_PATH = "' + $UO_BUNDLE_INSTALL_PATH + '"'   >> $HOME/.env_uo.ps1
'$env:PATH           = "' + $PATH     + '"'   >> $HOME/.env_uo.ps1
'$env:RUBYLIB        = "' + $RUBYLIB  + '"'   >> $HOME/.env_uo.ps1
'$env:RUBY_DLL_PATH  = "' + $RUBY_DLL_PATH  + '"'   >> $HOME/.env_uo.ps1

''  >> $HOME/.env_uo.bat
'SET "GEM_HOME=' + $GEM_HOME + '"'   >> $HOME/.env_uo.bat
'SET "GEM_PATH=' + $GEM_PATH + '"'   >> $HOME/.env_uo.bat
'SET "UO_GEMFILE_PATH=' + $UO_GEMFILE_PATH + '"'   >> $HOME/.env_uo.bat
'SET "UO_BUNDLE_INSTALL_PATH=' + $UO_BUNDLE_INSTALL_PATH + '"'   >> $HOME/.env_uo.bat
'SET "PATH=' + $PATH     + '"'   >> $HOME/.env_uo.bat
'SET "RUBYLIB=' + $RUBYLIB  + '"'   >> $HOME/.env_uo.bat
'SET "RUBY_DLL_PATH=' + $RUBY_DLL_PATH  + '"'   >> $HOME/.env_uo.bat
