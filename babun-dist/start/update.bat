@echo off
setlocal enableextensions enabledelayedexpansion

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set BABUN_HOME=%SCRIPT_PATH%
set DIST_DIR=%BABUN_HOME%/dist

:BEGIN
set CYGWIN_HOME=%BABUN_HOME%\cygwin
set AHK=%DIST_DIR%\tools\ahk.exe
set WGET=%CYGWIN_HOME%\bin\wget.exe
set BASH=%CYGWIN_HOME%\bin\bash.exe
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
echo [babun] Upgrading cygwin from %MIRROR%
echo [babun] Writing data to %DIST_DIR%

%BASH% -c "source ~/.babunrc; /bin/rm.exe -f '%DIST_DIR%/setup-x86.exe' '%DIST_DIR%/cygwin.version'" || goto :ERROR
%BASH% -c "source ~/.babunrc; /bin/wget.exe --directory-prefix='%DIST_DIR%' https://cygwin.com/setup-x86.exe" || goto :ERROR
%BASH% -c "source ~/.babunrc; /bin/wget.exe --directory-prefix='%DIST_DIR%' https://raw.githubusercontent.com/babun/babun-cygwin/master/cygwin.version" || goto :ERROR

GOTO SETUPPROXY

:SETUPPROXY
%BASH% -c "/bin/grep.exe 'export http_proxy=' ~/.babunrc | /bin/grep.exe -v '#' | /bin/cut.exe -d "@" -f 2 " > "%DIST_DIR%/proxy" 
set /p PROXY=<"%DIST_DIR%/proxy" 

if "%PROXY%" == "" (
    GOTO DIRECTDOWNLOAD
) ELSE (
    GOTO PROXYDOWNLOAD
)

:DIRECTDOWNLOAD
cd "%DIST_DIR%"
echo [babun] Downloading cygwin packages without proxy
echo [babun] Adjusting installation parameters
start %AHK%
setup-x86.exe --upgrade-also --site="%MIRROR%" --no-admin --no-shortcuts --no-startmenu --no-desktop --root="%CYGWIN_HOME%" --local-package-dir="%DIST_DIR%" || goto :ERROR
setup-x86.exe --quiet-mode --upgrade-also --site="%MIRROR%" --no-admin --no-shortcuts --no-startmenu --no-desktop --root="%CYGWIN_HOME%" --local-package-dir="%DIST_DIR%" || goto :ERROR
GOTO VERSION

:PROXYDOWNLOAD
cd "%DIST_DIR%"
echo [babun] Downloading cygwin packages with proxy=%PROXY%
echo [babun] Adjusting installation parameters
start %AHK%
setup-x86.exe --upgrade-also --site="%MIRROR%" --no-admin --no-shortcuts --no-startmenu --no-desktop --root="%CYGWIN_HOME%" --local-package-dir="%DIST_DIR%" --proxy=%PROXY% || goto :ERROR
setup-x86.exe --quiet-mode --upgrade-also --site="%MIRROR%" --no-admin --no-shortcuts --no-startmenu --no-desktop --root="%CYGWIN_HOME%" --local-package-dir="%DIST_DIR%" --proxy=%PROXY% || goto :ERROR
GOTO VERSION

:VERSION
copy /Y "%DIST_DIR%/cygwin.version" "%CYGWIN_HOME%/usr/local/etc/babun/installed/cygwin" || goto :ERROR
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

