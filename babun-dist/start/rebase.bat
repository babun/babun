@echo off
setlocal enableextensions enabledelayedexpansion

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set BABUN_HOME=%SCRIPT_PATH%

:BEGIN
set CYGWIN_HOME=%BABUN_HOME%\cygwin
set DASH=%CYGWIN_HOME%\bin\dash.exe
if not exist "%DASH%" goto NOTFOUND

:RUN
ECHO [babun] Runnig rebaseall
"%DASH%" -c '/usr/bin/rebaseall -v'
GOTO END

:NOTFOUND
ECHO [babun] dash.exe not found. Babun installation seems to be corrupted.
pause
EXIT /b 255

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
pause
EXIT /b %errorlevel%

:END
ECHO [babun] Finished rebaseall