@echo off
setlocal enableextensions enabledelayedexpansion

set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set BABUN_HOME=%SCRIPT_PATH%


:BEGIN
set CYGWIN_HOME=%BABUN_HOME%cygwin
IF not exist "%CYGWIN_HOME%\bin\mintty.exe" GOTO :NOTFOUND

:PARSEPARAMS
IF "%~1"=="" (
    GOTO :RUN
)
IF "%~1"=="--help" (
    GOTO :HELP
)
IF "%~1"=="-run" (
    set _params=%~2
    SHIFT
    SHIFT
    GOTO :PARSEPARAMS
)
set CHERE_INVOKING=1
IF "%~1"=="--here" (
    SHIFT
    GOTO :PARSEPARAMS
)
:: ELSE
if NOT "%_path%"=="" (
    ECHO Only one path may be specified!
    GOTO :END
)
cd /d %1
set %_path%=%1
SHIFT
GOTO :PARSEPARAMS


:RUN
ECHO [babun] Starting babun
IF NOT "%CHERE_INVOKING%"=="" (
    ECHO [babun] in: %cd%
)
IF NOT "%_params%"=="" (
    ECHO [babun] with parameters: %_params%
)
start "" "%CYGWIN_HOME%\bin\mintty.exe" %_params% || GOTO :ERROR
GOTO :END


:NOTFOUND
ECHO [babun] Start script not found. Babun installation seems to be corrupted.
EXIT /b 255

:ERROR
ECHO [babun] Terminating due to internal error #%errorlevel%
EXIT /b %errorlevel%

:HELP
ECHO usage: babun.bat [--help] [--here] [-run=^<command^>] [^<path^>]
ECHO Open the babun shell (mintty).
ECHO.
ECHO Parameters:
ECHO    --help
ECHO        Show this help message.
ECHO    --here
ECHO        Open shell in the current working directory.
ECHO    -run=^<command^>
ECHO        Run mintty with the arguments in command.
ECHO    ^<path^>
ECHO        Open shell in the specified directory.
ECHO        Overrides --here. May only occur once.
ECHO.

:END
