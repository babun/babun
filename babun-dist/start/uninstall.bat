@echo off
setlocal enableextensions enabledelayedexpansion

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set BABUN_HOME=%SCRIPT_PATH%

SET /p answer="Do you really want to uninstall babun (Y / N)?" 
IF "%answer:~0,1%"=="Y" GOTO UNIINSTALL
IF "%answer:~0,1%"=="y" GOTO UNIINSTALL
EXIT /b 255	

:UNIINSTALL
set CYGWIN_HOME=%BABUN_HOME%\cygwin

ECHO [babun] Uninstalling plugins...

"%CYGWIN_HOME%"\bin\bash.exe -l -c "/usr/local/etc/babun/source/babun-core/plugins/uninstall.sh" || GOTO :ERROR_CLEANUP

ECHO [babun] Deleting desktop shortcut...

DEL /F /Q "%USERPROFILE%\Desktop\babun.lnk" || ECHO "Could not delete desktop shortcut."

rem Quick solution for now
ECHO [babun] Deleting files and directories...

DEL /F /Q babun.bat || GOTO :ERROR_DELETE_FILES
DEL /F /Q update.bat || GOTO :ERROR_DELETE_FILES
DEL /F /Q rebase.bat || GOTO :ERROR_DELETE_FILES
RMDIR /S /Q tools || GOTO :ERROR_DELETE_FILES
RMDIR /S /Q fonts || GOTO :ERROR_DELETE_FILES
RMDIR /S /Q cygwin || GOTO :ERROR_DELETE_FILES

GOTO :SUCCESS

:ERROR_DELETE_FILES
ECHO [babun] Terminating due to internal error #%errorlevel%
ECHO [babun] Possibly some resources are stil in use. Make sure you closed all babun instances.
ECHO [babun] At this point you can simply delete the %SCRIPT_PATH% folder.
pause
EXIT /b %errorlevel%

:ERROR_CLEANUP
ECHO [babun] Terminating due to internal error #%errorlevel%
pause
EXIT /b %errorlevel%

:SUCCESS
ECHO [babun] Babun uninstalled successfully. Now you can delete the uninstaller from %SCRIPT_PATH%.
ECHO [babun] Good bye!