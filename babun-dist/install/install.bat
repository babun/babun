@echo off
setlocal enableextensions enabledelayedexpansion

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%

set BABUN_HOME=%USERPROFILE%\.babun
set CYGWIN_HOME=%BABUN_HOME%\cygwin

set INSTALLER_PATH=
set BABUN_ZIP=%SCRIPT_PATH%/dist/babun.zip
set UNZIPPER=%SCRIPT_PATH%/dist/unzip.exe

set SETPATH_SCRIPT=%BABUN_HOME%\tools\setpath.vbs
set LINK_SCRIPT=%BABUN_HOME%\tools\link.vbs
set LOG_FILE=%SCRIPT_PATH%/installer.log

:UNZIP
ECHO [babun] Installing babun
if exist "%BABUN_HOME%/*.*" (
 	ECHO [babun] Babun home alread exist: %BABUN_HOME%"
	ECHO [babun] Delete the old folder in order to proceed. Terminating!
	pause
 	EXIT /b 255
)
if not exist "%BABUN_HOME%" (mkdir "%BABUN_HOME%" || goto :ERROR)
ECHO [babun] Unzipping 

"%UNZIPPER%" "%BABUN_ZIP%" -d "%USERPROFILE%"
if not exist "%BABUN_HOME%/*.*" (GOTO ERROR)

:POSTINSTALL
ECHO [babun] Running post-installation scripts. It may take a while...
%CYGWIN_HOME%\bin\dash.exe -c "/usr/bin/rebaseall" || goto :ERROR
%CYGWIN_HOME%\bin\bash.exe --norc --noprofile -c "/usr/local/etc/babun/source/babun-core/tools/post_extract.sh" || goto :ERROR
rem execute any command with -l (login) to run the post-installation scripts
%CYGWIN_HOME%\bin\bash.exe -l -c "date; rm -rf /usr/local/etc/babun/stamps/check; rm -rf /usr/local/etc/babun/stamps/welcome;" || goto :ERROR

:PATH
ECHO [babun] Adding babun to the system PATH variable
if not exist "%SETPATH_SCRIPT%" (
    ECHO [babun] ERROR: Cannot add babun to the system PATH variable. Script not found!
)
cscript //Nologo "%SETPATH_SCRIPT%" "%BABUN_HOME%"

:LINK
ECHO [babun] Creating a desktop link
if not exist "%LINK_SCRIPT%" (
    ECHO [babun] ERROR: Cannot create a desktop link. Script not found!
)
cscript //Nologo "%LINK_SCRIPT%" "%USERPROFILE%\Desktop\babun.lnk" "%BABUN_HOME%\babun.bat"

:INSTALLED
ECHO [babun] Babun installed successfully. You can delete the the installer now.
ECHO [babun] Enjoy! @tombujok

:RUN
ECHO [babun] Starting babun
start %BABUN_HOME%\babun.bat || goto :ERROR
GOTO END

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:END 

