@echo off
setlocal enableextensions enabledelayedexpansione

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set BABUN_HOME=%SCRIPT_PATH%

:BEGIN
set CYGWIN_HOME=%BABUN_HOME%\cygwin
set WGET=%CYGWIN_HOME%\bin\wget.exe
if exist "%WGET%" goto RUN
if not exist "%WGET%" goto NOTFOUND

:RUN
ECHO [babun] Upgrading cygwin
set DIST_DIR=dist
set MIRROR=http://mirrors.kernel.org/sourceware/cygwin
if exist %DIST_DIR% rmdir %DIST_DIR% /s /q
%WGET% --timestamping --directory-prefix=%DIST_DIR% https://cygwin.com/setup-x86.exe || goto :ERROR
cd %DIST_DIR%
setup-x86.exe --upgrade-also --site=%MIRROR% --quiet-mode --no-admin --root=%CYGWIN_HOME% || goto :ERROR
GOTO END

:NOTFOUND
ECHO [babun] Wget not found. Babun installation seems to be corrupted.
EXIT /b 255

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:END
