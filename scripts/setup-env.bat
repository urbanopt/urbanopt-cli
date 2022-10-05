IF "%HOMEPATH%"=="" ECHO HOMEPATH is NOT defined. Please set this env value to your home directory before running this script. 
IF "%HOMEPATH%"=="" exit /B

SET BASE_DIR_NAME=%~d0%~p0

SET GEM_HOME=%BASE_DIR_NAME%\gems\ruby\2.7.0
SET GEM_PATH=%BASE_DIR_NAME%\gems\ruby\2.7.0
SET PATH=%BASE_DIR_NAME%\ruby\bin;%BASE_DIR_NAME%\gems\ruby\2.7.0\bin;%PATH%
SET RUBYLIB=%BASE_DIR_NAME%\OpenStudio\Ruby
SET RUBY_DLL_PATH=%BASE_DIR_NAME%\OpenStudio\Ruby

IF EXIST %HOMEPATH%\.env_uo.bat (
  del "%HOMEPATH%\.env_uo.bat"
) 

echo SET "GEM_HOME=%GEM_HOME%">> "%HOMEPATH%\.env_uo.bat"
echo SET "GEM_PATH=%GEM_PATH%">> "%HOMEPATH%\.env_uo.bat"
echo SET "PATH=%PATH%">> "%HOMEPATH%\.env_uo.bat"
echo SET "RUBYLIB=%RUBYLIB%">> "%HOMEPATH%\.env_uo.bat"
echo SET "RUBY_DLL_PATH=%RUBY_DLL_PATH%">> "%HOMEPATH%\.env_uo.bat"

