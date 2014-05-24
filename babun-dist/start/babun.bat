@echo off
setlocal enableextensions enabledelayedexpansion
set CONFIG_FILE=custom_install.config

if not "%BABUN_HOME%" == "" (
	set CONFIG_FILE=%BABUN_HOME%\%CONFIG_FILE%
)
if exist "%CONFIG_FILE%" (
	set /p BABUN_HOME=<custom_install.config
	goto BEGIN
)
set BABUN_HOME=%USERPROFILE%\.babun

:BEGIN
set CYGWIN_HOME=%BABUN_HOME%\cygwin
if exist "%CYGWIN_HOME%\bin\mintty.exe" goto RUN
if not exist "%CYGWIN_HOME%\bin\mintty.exe" goto NOTFOUND

:RUN
rem ECHO [babun] Registering temporary fonts
rem %BABUN_HOME%\fonts\RegisterFont.exe rem "%BABUN_HOME%\fonts\Menlo\Menlo Bold for Powerline.ttf" "%BABUN_HOME%\fonts\Menlo\Menlo Bold Italic for Powerline.ttf" "%BABUN_HOME%\fonts\Menlo\Menlo Italic for Powerline.ttf" "%BABUN_HOME%\fonts\Menlo\Menlo Regular for Powerline.ttf" 
rem %BABUN_HOME%\fonts\RegisterFont.exe add "%BABUN_HOME%\fonts\Menlo\Menlo Bold for Powerline.ttf" "%BABUN_HOME%\fonts\Menlo\Menlo Bold Italic for Powerline.ttf" "%BABUN_HOME%\fonts\Menlo\Menlo Italic for Powerline.ttf" "%BABUN_HOME%\fonts\Menlo\Menlo Regular for Powerline.ttf" 

ECHO [babun] Starting babun
rem start %CYGWIN_HOME%\bin\mintty.exe --size 100,35 -o Font='Menlo Regular for Powerline' - || goto :ERROR
start %CYGWIN_HOME%\bin\mintty.exe - || goto :ERROR
GOTO END

:NOTFOUND
ECHO [babun] Start script not found. Did you delete the the .babun folder from the USER_HOME?
EXIT /b 255

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:END
