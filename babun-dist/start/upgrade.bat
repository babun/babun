@echo off
setlocal enableextensions enabledelayedexpansione

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set BABUN_HOME=%SCRIPT_PATH%

:BEGIN
set CYGWIN_HOME=%BABUN_HOME%\cygwin
set WGET=%CYGWIN_HOME%\bin\wget.exe
if exist "%WGET%" goto SELECTSITE
if not exist "%WGET%" goto NOTFOUND

:SELECTSITE
if %1.==. (
	set MIRROR=http://mirrors.kernel.org/sourceware/cygwin
	GOTO RUN
)	
if "%1"=="/s" GOTO SETSITE
if "%1"=="/site" GOTO SETSITE
GOTO UNKNOWNFLAG

:SETSITE
if %2.==. (
	GOTO MIRRORNOTSET
)
set MIRROR=%2
GOTO RUN

:RUN
ECHO [babun] Upgrading cygwin from %MIRROR%
set DIST_DIR=dist
if exist %DIST_DIR% rmdir %DIST_DIR% /s /q
%WGET% --timestamping --directory-prefix=%DIST_DIR% https://cygwin.com/setup-x86.exe || goto :ERROR
cd %DIST_DIR%
setup-x86.exe --upgrade-also --site=%MIRROR% --quiet-mode --no-admin --root=%CYGWIN_HOME% || goto :ERROR
GOTO END

:MIRRORNOTSET
ECHO [babun] /SITE flag was set, but no mirror was provided. Please add site URL. Terminating!
pause
EXIT /b 255

:UNKNOWNFLAG
ECHO [babun] Unknown flag provided. Terminating!
pause
EXIT /b 255

:NOTFOUND
ECHO [babun] Wget not found. Babun installation seems to be corrupted.
EXIT /b 255

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:END
