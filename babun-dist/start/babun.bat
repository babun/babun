@echo off
setlocal enableextensions enabledelayedexpansion

set BABUN_HOME=%USERPROFILE%\.babun
set CYGWIN_HOME=%BABUN_HOME%\cygwin

:BEGIN
if exist "%CYGWIN_HOME%\bin\mintty.exe" goto RUN
if not exist "%CYGWIN_HOME%\bin\mintty.exe" goto NOTFOUND

:RUN
ECHO [babun] Registering temporary fonts
%BABUN_HOME%\fonts\RegisterFont.exe add "%BABUN_HOME%\fonts\Meslo LG L DZ Regular for Powerline.otf" "%BABUN_HOME%\fonts\Meslo LG L Regular for Powerline.otf" "%BABUN_HOME%\fonts\Meslo LG M DZ Regular for Powerline.otf" "%BABUN_HOME%\fonts\Meslo LG M Regular for Powerline.otf" "%BABUN_HOME%\fonts\Meslo LG S DZ Regular for Powerline.otf" "%BABUN_HOME%\fonts\Meslo LG S Regular for Powerline.otf"

ECHO [babun] Starting babun
start %CYGWIN_HOME%\bin\mintty.exe -o Font='Meslo LG M Regular for Powerline' - || goto :ERROR
GOTO END

:NOTFOUND
ECHO [babun] Start script not found. Did you delete the the .babun folder from the USER_HOME?
EXIT /b 255

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:END