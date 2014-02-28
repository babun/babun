@echo off
setlocal enableextensions enabledelayedexpansion

set BABUN_HOME=%USERPROFILE%\.babun
set CYGWIN_HOME=%BABUN_HOME%\cygwin

:BEGIN
if exist "%CYGWIN_HOME%\bin\mintty.exe" goto RUN
if not exist "%CYGWIN_HOME%\bin\mintty.exe" goto NOTFOUND

:RUN
ECHO [babun] Registering temporary fonts
%BABUN_HOME%\fonts\RegisterFont.exe add "%BABUN_HOME%\fonts\Menlo\Menlo Bold for Powerline.ttf" "%BABUN_HOME%\fonts\Menlo\Menlo Bold Italic for Powerline.ttf" "%BABUN_HOME%\fonts\Menlo\Menlo Italic for Powerline.ttf" "%BABUN_HOME%\fonts\Menlo\Menlo Regular for Powerline.ttf" 

ECHO [babun] Starting babun
start %CYGWIN_HOME%\bin\mintty.exe -o Font='Menlo Regular for Powerline' - || goto :ERROR
GOTO END

:NOTFOUND
ECHO [babun] Start script not found. Did you delete the the .babun folder from the USER_HOME?
EXIT /b 255

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:END