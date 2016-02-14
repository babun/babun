@echo off
setlocal enableextensions enabledelayedexpansion

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set CUSTOM=false
set INSTALLER_PATH=
set BABUN_ZIP=%SCRIPT_PATH%/dist/babun.zip
set UNZIPPER=%SCRIPT_PATH%/dist/unzip.exe
set FREESPACE_SCRIPT=%SCRIPT_PATH%/dist/freespace.vbs
set LOG_FILE=%SCRIPT_PATH%/installer.log

ECHO [babun] Installing babun

if %1.==. (
	set BABUN_HOME=%USERPROFILE%\.babun
	set TARGET=%USERPROFILE%
	GOTO CHECKTARGET
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
ECHO [babun] Installing to: "%BABUN_HOME%"
GOTO CHECKTARGET

:NOTARGET
ECHO [babun] Target flag set but no target provided:
ECHO [babun] install.bat /target "D:\target_folder"
ECHO [babun] Retry with a target specified. Terminating!
pause
EXIT /b 255

:CHECKTARGET
rem NOTHING FOR NOW

:CHECKFREESPACE	
set DRIVE_LETTER=%BABUN_HOME:~0,2%
FOR /F "usebackq tokens=*" %%r in (`cscript //Nologo "%FREESPACE_SCRIPT%" "%DRIVE_LETTER%"`) DO SET FREE_SPACE=%%r

REM Check whether the cscript command returned text or number
SET "istext="&for /f "delims=0123456789" %%i in ("%FREE_SPACE%") do set "istext=%%i"
if defined istext (
    ECHO [babun] ERROR: %FREE_SPACE%
    ECHO [babun] ERROR: Unable to run .vbs script to determine free space on drive.
    ECHO [babun] ERROR: This is often caused by anti-virus applications blocking execution of .vbs files.
    ECHO [babun] ERROR: If you are sure that you have enough disk space, you can continue at your own risk.
    CHOICE /M "[babun] Do you want to continue? "
    IF ERRORLEVEL 2 exit /b 255
    GOTO CHECKHOME
)

if %FREE_SPACE% lss 1024 (
	ECHO [babun] ERROR: There is not enough space on your destination drive %DRIVE_LETTER%
	ECHO [babun] ERROR: Babun requires at least 1024 MB to operate properly
	ECHO [babun] ERROR: Free Space on %DRIVE_LETTER% %FREE_SPACE% MB
	ECHO [babun] ERROR: Please install babun to another destination using the /target option:
	ECHO [babun] install.bat /target "D:\target_folder"
    PAUSE
	EXIT /b 255
)

:CHECKHOME
IF "%HOME%"=="" (
	ECHO [babun] HOME variable not set
	GOTO UNZIP
)

:SKIPHOMESET
IF "%NOCHECK%"=="true" (
	ECHO [babun] WARN: NOCHECK set to true	
	GOTO UNZIP
)

:HOMESET	
ECHO [babun] WARN: Windows HOME environment variable is set to: %HOME%
ECHO [babun] WARN: ---------------------------------------------------------------
ECHO [babun] WARN: FULL COMPATIBILITY CANNOT BE GUARANTEED WHEN 'HOME' IS SET
ECHO [babun] WARN: YOU MAY RUN INTO MANY ISSUES THAT CANNOT BE FORESEEN... 
ECHO [babun] WARN: ---------------------------------------------------------------
ECHO [babun] WARN: It's recommended to remove the HOME variable and try again.
ECHO [babun] WARN: If you are running the installer from a cmd.exe - restart it.
ECHO [babun] WARN: Otherwise the ENV variables will not be propagated to cmd.exe
SET /p answer="Do you really wish to proceed (Y / N)?" 
IF "%answer:~0,1%"=="Y" GOTO UNZIP
IF "%answer:~0,1%"=="y" GOTO UNZIP
EXIT /b 255	 

:UNZIP
set CYGWIN_HOME=%BABUN_HOME%\cygwin

if exist "%BABUN_HOME%/*.*" (
 	ECHO [babun] Babun home already exists: "%BABUN_HOME%"
	ECHO [babun] Delete the old folder in order to proceed. Terminating!
	pause
 	EXIT /b 255
)
if not exist "%BABUN_HOME%" (mkdir "%BABUN_HOME%" || goto :ERROR)
ECHO [babun] Unzipping 

"%UNZIPPER%" "%BABUN_ZIP%" -d "%TARGET%"
if not exist "%BABUN_HOME%/*.*" (GOTO ERROR)

:POSTINSTALL
set SETPATH_SCRIPT=%BABUN_HOME%\tools\setpath.vbs
set LINK_SCRIPT=%BABUN_HOME%\tools\link.vbs

ECHO [babun] Running post-installation scripts. It may take a while...
"%CYGWIN_HOME%"\bin\dash.exe -c "/usr/bin/rebaseall" || goto :ERROR
"%CYGWIN_HOME%"\bin\bash.exe --norc --noprofile -c "/usr/local/etc/babun/source/babun-core/tools/post_extract.sh" || goto :ERROR
rem execute any command with -l (login) to run the post-installation scripts
"%CYGWIN_HOME%"\bin\bash.exe -l -c "date" || goto :ERROR
"%CYGWIN_HOME%"\bin\bash.exe -l -c "cat /usr/local/etc/babun/source/babun.version > /usr/local/etc/babun/installed/babun"  || goto :ERROR
"%CYGWIN_HOME%"\bin\bash.exe -l -c "/usr/local/etc/babun/source/babun-core/plugins/install_home.sh" || goto :ERROR

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
cscript //Nologo "%LINK_SCRIPT%" "%USERPROFILE%\Desktop\babun.lnk" "%BABUN_HOME%"\cygwin\bin\mintty.exe

:INSTALLED
ECHO [babun] Babun installed successfully. You can delete the installer now.
ECHO [babun] Enjoy! Babun Team (http://babun.github.io).

:RUN
ECHO [babun] Starting babun
"%BABUN_HOME%"\babun.bat || goto :ERROR
GOTO END

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:END 
pause
