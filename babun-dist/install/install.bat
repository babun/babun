@echo off
setlocal enableextensions enabledelayedexpansion

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set CUSTOM=false
set INSTALLER_PATH=
set BABUN_ZIP=%SCRIPT_PATH%/dist/babun.zip
set UNZIPPER=%SCRIPT_PATH%/dist/unzip.exe
set LOG_FILE=%SCRIPT_PATH%/installer.log

ECHO [babun] Installing babun

if %1.==. (
	set BABUN_HOME=%USERPROFILE%\.babun
	set TARGET=%USERPROFILE%
	GOTO CHECKSIZE
)	
if "%1"=="/t" GOTO TARGET
if "%1"=="/target" (GOTO TARGET || GOTO UNKNOWNFLAG)

:UNKNOWNFLAG
ECHO [babun] Unknown flag provided. Terminating!
pause
EXIT /b 255

:TARGET
if %2.==. GOTO NOTARGET
set BABUN_HOME=%~2\.babun
set TARGET=%~2
set CUSTOM=true
ECHO [babun] Target flag set
ECHO [babun] Installing to: "%BABUN_HOME%"
GOTO CHECKSIZE

:NOTARGET
ECHO [babun] Target flag set but no target provided:
ECHO [babun] install.bat /target "D:\your_custom_directory"
ECHO [babun] Retry with a target specified. Terminating!
pause
EXIT /b 255

:CHECKSIZE
set /a count=0
for %%x in (%BABUN_HOME%) do set /a count+=1
if %count% gtr 1 (
	ECHO [babun] ERROR: Destination directory contains spaces or illegal characters
	ECHO [babun] %BABUN_HOME%
	ECHO [babun] Please use another destination with the command:
	ECHO [babun] install.bat /target "x:/your_custom_directory"
	ECHO [babun] Retry with a different target. Terminating!
	pause
	EXIT /b 255
)

set DRIVE_LETTER=%BABUN_HOME:~0,2%
set /a freeSpace=0
for /f "skip=1 tokens=1,2" %%A in ('wmic volume where "driveLetter='%DRIVE_LETTER%'" get freespace') do (
	if "%%B" neq "" for /f %%N in ('powershell !freeSpace!+%%A/1048576') do (
		set freeSpace=%%N
	)
)

if freeSpace lss 800 (
	ECHO [babun] ERROR: There is not enough space on your destination drive
	ECHO [babun] Babun requires 800MB of free space to complete installation
	ECHO [babun] Drive: %DRIVE_LETTER%
	ECHO [babun] Free Space: %freeSpace%MB
	ECHO [babun] Please use another destination with the command:
	ECHO [babun] install.bat /target "x:/your_custom_directory"
	ECHO [babun] Retry with a different target. Terminating!
	pause
	EXIT /b 255
)
echo [babun] There is %freeSpace% MB of Free Space Available on %DRIVE_LETTER%
echo [babun] Babun takes up approx. 650MB
set /p answer=Do you wish to proceed (Y / N)? 
if "%answer:~0,1%"=="Y" GOTO UNZIP
if "%answer:~0,1%"=="y" GOTO UNZIP
EXIT /b 255

:UNZIP
set SETPATH_SCRIPT=%BABUN_HOME%\tools\setpath.vbs
set LINK_SCRIPT=%BABUN_HOME%\tools\link.vbs
set CYGWIN_HOME=%BABUN_HOME%\cygwin

if exist "%BABUN_HOME%/*.*" (
 	ECHO [babun] Babun home already exists: %BABUN_HOME%"
	ECHO [babun] Delete the old folder in order to proceed. Terminating!
	pause
 	EXIT /b 255
)
if not exist "%BABUN_HOME%" (mkdir "%BABUN_HOME%" || goto :ERROR)
if "%CUSTOM%"=="true" ECHO %BABUN_HOME%>%BABUN_HOME%\custom_install.config
ECHO [babun] Unzipping 

"%UNZIPPER%" "%BABUN_ZIP%" -d "%TARGET%"
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
if exist "%USERPROFILE%\Desktop\babun.lnk" (
    ECHO [babun] Deleting old desktop link
    DEL /F /Q "%USERPROFILE%\Desktop\babun.lnk"
)
ECHO [babun] Creating a desktop link
if not exist "%LINK_SCRIPT%" (
    ECHO [babun] ERROR: Cannot create a desktop link. Script not found!
)
cscript //Nologo "%LINK_SCRIPT%" "%USERPROFILE%\Desktop\babun.lnk" "%BABUN_HOME%\babun.bat"

:INSTALLED
ECHO [babun] Babun installed successfully. You can delete the installer now.
ECHO [babun] Enjoy! @tombujok

:RUN
ECHO [babun] Starting babun
%BABUN_HOME%\babun.bat || goto :ERROR
GOTO END

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:END 
pause
