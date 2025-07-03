IF "%HOMEPATH%"=="" ECHO HOMEPATH is NOT defined. Please set this env value to your home directory before running this script. 
IF "%HOMEPATH%"=="" exit /B

SET RUBY_BASE_VERSION=3.2.0
SET MINICONDA_VERSION=24.9.2-0
SET BASE_DIR_NAME=%~d0%~p0

SET GEM_HOME=%BASE_DIR_NAME%\gems\ruby\%RUBY_BASE_VERSION%
SET GEM_PATH=%BASE_DIR_NAME%\gems\ruby\%RUBY_BASE_VERSION%
SET PATH=%BASE_DIR_NAME%\ruby\bin;%BASE_DIR_NAME%\gems\ruby\%RUBY_BASE_VERSION%\bin;%PATH%
SET RUBYLIB=%BASE_DIR_NAME%\OpenStudio\Ruby
SET RUBY_DLL_PATH=%BASE_DIR_NAME%\OpenStudio\Ruby

%BASE_DIR_NAME%\gems\ruby\%RUBY_BASE_VERSION%\gems\$%BASE_DIR_NAME%/example_files/python_deps/Miniconda-%MINICONDA_VERSION=%/bin


IF EXIST %HOMEPATH%\.env_uo.bat (
  del "%HOMEPATH%\.env_uo.bat"
) 

echo SET "GEM_HOME=%GEM_HOME%">> "%HOMEPATH%\.env_uo.bat"
echo SET "GEM_PATH=%GEM_PATH%">> "%HOMEPATH%\.env_uo.bat"
echo SET "PATH=%PATH%">> "%HOMEPATH%\.env_uo.bat"
echo SET "RUBYLIB=%RUBYLIB%">> "%HOMEPATH%\.env_uo.bat"
echo SET "RUBY_DLL_PATH=%RUBY_DLL_PATH%">> "%HOMEPATH%\.env_uo.bat"

