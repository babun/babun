@echo off
setlocal enableextensions enabledelayedexpansion

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%

set BABUN_HOME=%USERPROFILE%\.babun
set CYGWIN_HOME=%BABUN_HOME%\cygwin

set INSTALLER_PATH=
set BABUN_ZIP=%SCRIPT_PATH%/babun.zip
set UNZIPPER=%SCRIPT_PATH%/unzip.exe

set SETPATH_SCRIPT=%BABUN_HOME%\tools\setpath.vbs
set LINK_SCRIPT=%BABUN_HOME%\tools\link.vbs
set LOG_FILE=%SCRIPT_PATH%/installer.log

:UNZIP
ECHO [babun] Installing babun
if exist "%BABUN_HOME%/*.*" (
 	ECHO [babun] Babun home alread exist: %BABUN_HOME%"
	ECHO [babun] Delete the old folder in order to proceed. Terminating!
 	EXIT /b 255
)
if not exist "%BABUN_HOME%" (mkdir "%BABUN_HOME%" || goto :ERROR)
ECHO [babun] Unzipping 

"%UNZIPPER%" "%BABUN_ZIP%" -d "%USERPROFILE%"
if not exist "%BABUN_HOME%/*.*" (GOTO ERROR)

:PATH
ECHO [babun] Adding babun to the system PATH variable
if not exist "%SETPATH_SCRIPT%" (
    ECHO [babun] Cannot add babun to the system PATH variable. Script not found!
    EXIT /b 255
)
cscript //Nologo "%SETPATH_SCRIPT%" "%BABUN_HOME%"

:LINK
ECHO [babun] Creating a desktop link
if not exist "%LINK_SCRIPT%" (
    ECHO [babun] Cannot create a desktop link. Script not found!
    EXIT /b 255
)
cscript //Nologo "%LINK_SCRIPT%" "%USERPROFILE%\Desktop\babun.lnk" "%CYGWIN_HOME%\bin\mintty.exe" " - "

:INSTALLED
ECHO [babun] Babun installed successfully. You can delete the the installer.

:FIXSYMLINKS
ECHO [babun] Fixing broken symlinks. It may take a while...
%CYGWIN_HOME%\bin\bash.exe --norc --noprofile -c "/bin/dos2unix.exe /etc/postinstall/symlinks_repair.sh" || goto :ERROR
%CYGWIN_HOME%\bin\bash.exe --norc --noprofile "/etc/postinstall/symlinks_repair.sh" || goto :ERROR
%CYGWIN_HOME%\bin\bash.exe --norc --noprofile -c "/bin/mv.exe /etc/postinstall/symlinks_repair.sh /etc/postinstall/symlinks_repair.sh.done" || goto :ERROR

:FIXUSERPROFILE
ECHO [babun] Fixing user profile.
%CYGWIN_HOME%\bin\bash.exe --norc --noprofile -c "/bin/rm -rf /home/*; /bin/mkpasswd.exe -l -c >> /etc/passwd; /bin/mkgroup -l -c >> /etc/group" || goto :ERROR
rem execute any command with -l (login) to run the installation scripts
%CYGWIN_HOME%\bin\bash.exe -l -c "date" || goto :ERROR

:RUN
ECHO [babun] Starting babun
start %CYGWIN_HOME%\bin\mintty.exe - || goto :ERROR
GOTO END

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:END

