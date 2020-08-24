SET BASE_DIR_NAME=%cd%

SET GEM_HOME=%BASE_DIR_NAME%\gems
SET GEM_PATH=%BASE_DIR_NAME%\gems
SET PATH=%BASE_DIR_NAME%\ruby\bin;%BASE_DIR_NAME%\gems\bin;%PATH%
SET RUBYLIB=%BASE_DIR_NAME%\OpenStudio\Ruby
SET RUBY_DLL_PATH=%BASE_DIR_NAME%\OpenStudio\Ruby

IF EXIST %HOME%\.env_uo.bat (
  del %HOME%\.env_uo.bat
) 

echo SET GEM_HOME=%GEM_HOME%>> %HOME%\.env_uo.bat
echo SET GEM_PATH=%GEM_PATH%>> %HOME%\.env_uo.bat
echo SET PATH=%PATH%>> %HOME%\.env_uo.bat
echo SET RUBYLIB=%RUBYLIB%>> %HOME%\.env_uo.bat
echo SET RUBY_DLL_PATH=%RUBY_DLL_PATH%>> %HOME%\.env_uo.bat


