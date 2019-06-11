@echo off
setlocal enableextensions enabledelayedexpansion

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set BABUN_HOME=%SCRIPT_PATH%
set DIST_DIR=%BABUN_HOME%/dist

:BEGIN
set CYGWIN_HOME=%BABUN_HOME%\cygwin
set WGET=%CYGWIN_HOME%\bin\wget.exe
set BASH=%CYGWIN_HOME%\bin\bash.exe

if not exist "%WGET%" goto NOTFOUND

:PARSE
IF "%~1"=="" (
	GOTO RUN
)

:PARSESITE
if "%~1"=="/site" (
	GOTO DOPARSESITE
)
GOTO AFTERPARSESITE

:DOPARSESITE
	SHIFT
	if %~1.==. (
		GOTO MIRRORNOTSET
	)
	set MIRROR=%~1
	SHIFT
	GOTO PARSE
)

:AFTERPARSESITE

:PARSEPROXY
if "%~1"=="/proxy" (
	GOTO DOPARSEPROXY
)
GOTO AFTERPARSEPROXY

:DOPARSEPROXY
	SHIFT
	if %~1.==. (
		GOTO PROXYNOTSET
	)
	set PROXY=%~1
	SHIFT
	GOTO PARSE
)
:AFTERPARSEPROXY

GOTO UNKNOWNFLAG

:RUN
if "%MIRROR%"=="" (
	set MIRROR=http://mirrors.kernel.org/sourceware/cygwin
	GOTO RUN
)

echo [babun] Upgrading Cygwin from %MIRROR%
echo [babun] Writing data to %DIST_DIR%

"%BASH%" -c "source ~/.babunrc; /bin/rm.exe -f '%DIST_DIR%/setup-x86.exe' '%DIST_DIR%/cygwin.version'" || goto :ERROR
echo download cyg version
"%BASH%" -c "source ~/.babunrc; /bin/wget.exe --no-check-certificate --directory-prefix='%DIST_DIR%' https://raw.githubusercontent.com/babun/babun-cygwin/master/cygwin.version" || goto :ERROR
set /p CYGWIN_VERSION=<"%DIST_DIR%/cygwin.version"
echo [babun] Downloading Cygwin %CYGWIN_VERSION%
"%BASH%" -c "source ~/.babunrc; /bin/wget.exe --no-check-certificate --directory-prefix='%DIST_DIR%' https://raw.githubusercontent.com/babun/babun-cygwin/%CYGWIN_VERSION%/babun-cygwin/setup-x86.exe" || goto :ERROR

:SETUPRC
echo [babun] Preparing setup.rc config
"%BASH%" -c "source ~/.babunrc; /bin/rm.exe -f /etc/setup/setup.rc" || goto :ERROR

:RUNNINGCHECK
"%BASH%" -c "source ~/.babunrc; /bin/ps.exe | /bin/grep.exe /usr/bin/mintty | /bin/wc.exe -l" > "%DIST_DIR%/running_count"
set /p RUNNING_COUNT=<"%DIST_DIR%/running_count"	

if NOT "%RUNNING_COUNT%"=="0" (
	echo [babun] ERROR: There's %RUNNING_COUNT% running babun instance[s]. Close all babun windows [mintty processes] and try again.
	GOTO BABUNRUNNING
)

"%BASH%" -c "source ~/.babunrc; /bin/rm.exe -f /etc/setup/setup.rc;" || goto :ERROR
rem Due to bug in setup.exe's quiet-mode the /etc/setup/setup.rc file is not read anyway...
rem "%BASH%" -c "source ~/.babunrc; /bin/echo.exe 'net-method' >> /etc/setup/setup.rc" || goto :ERROR
rem "%BASH%" -c "source ~/.babunrc; /bin/echo.exe '	IE' >> /etc/setup/setup.rc" || goto :ERROR
rem "%BASH%" -c "source ~/.babunrc; /bin/echo.exe 'last-action' >> /etc/setup/setup.rc" || goto :ERROR
rem "%BASH%" -c "source ~/.babunrc; /bin/echo.exe '	Download,Install' >> /etc/setup/setup.rc" || goto :ERROR

:SETUPPROXY
if "%PROXY%"=="" (
	echo [babun] Proxy flag not set, trying to read the proxy from ~/.babunrc
	"%BASH%" -c "source ~/.babunrc && echo $http_proxy | /bin/sed.exe 's,http://,,g' | /bin/gawk.exe '{n=split($0,a,\"@\"); print a[n]}'" > "%DIST_DIR%/proxy"
	set /p PROXY=<"%DIST_DIR%/proxy"
)

if "%PROXY%" == "" (
    GOTO DIRECTDOWNLOAD
) ELSE (
    GOTO PROXYDOWNLOAD
)

:DIRECTDOWNLOAD
cd "%DIST_DIR%"
echo [babun] Executing Cygwin upgrade without proxy
setup-x86.exe --quiet-mode --upgrade-also --site="%MIRROR%" --no-admin --no-shortcuts --no-startmenu --no-desktop --root="%CYGWIN_HOME%" --local-package-dir="%DIST_DIR%" || goto :ERROR
GOTO VERSION

:PROXYDOWNLOAD
cd "%DIST_DIR%"
echo [babun] Executing Cygwin upgrade with proxy=%PROXY%
setup-x86.exe --quiet-mode --upgrade-also --site="%MIRROR%" --no-admin --no-shortcuts --no-startmenu --no-desktop --root="%CYGWIN_HOME%" --local-package-dir="%DIST_DIR%" --proxy="%PROXY%" || goto :ERROR
GOTO VERSION

:VERSION
echo [babun] Updating Cygwin version number
copy /Y "%DIST_DIR%/cygwin.version" "%CYGWIN_HOME%/usr/local/etc/babun/installed/cygwin" || goto :ERROR
GOTO CYGFIX

:CYGFIX
"%BASH%" -c "source /usr/local/etc/babun/source/babun-core/plugins/cygfix/install.sh" || goto :ERROR
GOTO END

:MIRRORNOTSET
ECHO [babun] /site flag was given, but no site was provided. Please add the site URL. Terminating!
pause
EXIT /b 255

:PROXYNOTSET
ECHO [babun] /proxy flag was given, but no proxy was provided. Please add proxy URL. Terminating!
pause
EXIT /b 255


:UNKNOWNFLAG
ECHO [babun] Unknown flag provided. Terminating!
pause
EXIT /b 255

:NOTFOUND
ECHO [babun] Wget not found. Babun installation seems to be corrupted.
pause
EXIT /b 255

:BABUNRUNNING
ECHO [babun] Terminating!
pause
EXIT /b 255

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
ECHO [babun] Execute %BABUN_HOME%/update.bat to rerun the Cygwin update process.
pause
EXIT /b %errorlevel%

:END
ECHO [babun] Full success - starting babun
start "" "%CYGWIN_HOME%\bin\mintty.exe" - || goto :ERROR
