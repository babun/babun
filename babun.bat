@echo off
setlocal enableextensions enabledelayedexpansion

:SETUP
set CYGWIN_VERSION=x86
set PROXY=
set FORCE=false

set BABUN_HOME=%USERPROFILE%\.babun\
set DOWNLOADS=%BABUN_HOME%\downloads\
set CYGWIN_HOME=%BABUN_HOME%\cygwin\
set PACKAGES_HOME=%BABUN_HOME%\packages\

set DOWNLOADER=%DOWNLOADS%\download.vbs
set UNZIPPER=%DOWNLOADS%\unzip.exe
set CYGWIN_INSTALLER=%DOWNLOADS%\%CYGWIN_INSTALLER%setup-%CYGWIN_VERSION%.exe
set PACKAGES=%DOWNLOADS%\packages-%CYGWIN_VERSION%.zip

set CYGWIN_SETUP_URL=http://cygwin.com/setup-%CYGWIN_VERSION%.exe
set PACKAGES_URL=https://babun.svn.cloudforge.com/packages/packages-%CYGWIN_VERSION%.zip
set UNZIP_URL=http://stahlworks.com/dev/unzip.exe

:CHECKFORSWITCHES
IF '%1'=='/h' GOTO INFO
IF '%1'=='/64' GOTO VERSION64
IF '%1'=='/force' GOTO FORCE
IF '%1'=='/proxy' GOTO PROXY
IF '%1'=='' (GOTO BEGIN) ELSE (GOTO BADSYNTAX)
REM Done checking command line for switches
GOTO BEGIN
REM
REM
:VERSION64
SET CYGWIN_VERSION=x86_64
SHIFT
GOTO CHECKFORSWITCHES
REM
:FORCE
SET FORCE=true
SHIFT
GOTO CHECKFORSWITCHES
REM
:PROXY
set line=%2
	set i=0
	rem fetch proxy tokens to an array
	:TOKEN
	for /f "tokens=1* delims=:" %%a in ("!line!") do (		
		set array[!i!]=%%a
		set /A i+=1	
		set line=%%b
		if not "%line%" == "" goto :TOKEN
	)
	rem parse and validate proxy tokens
	if [%array[0]%] NEQ  [] (
		if [%array[1]%] == [] (GOTO :BADSYNTAX)
		set PROXY=%array[0]%:%array[1]%
	)
	if [%array[2]%] NEQ  [] (
		if [%array[3]%] == [] (GOTO :BADSYNTAX)
		set PROXY_USER=%array[2]%
		set PROXY_PASS=%array[3]%
	)
SHIFT
SHIFT
GOTO CHECKFORSWITCHES
REM


:BEGIN
echo version=%CYGWIN_VERSION%
echo force=%FORCE%
echo proxy_host=%PROXY%
echo proxy_user=%PROXY_USER%
echo proxy_pass=%PROXY_PASS%
echo.

if not exist %BABUN_HOME% (
	echo Creating Babun home folder
	mkdir %BABUN_HOME%
)

if not exist %DOWNLOADS% (
	echo Creating downloads home folder
	mkdir %DOWNLOADS%
)

if not exist %CYGWIN_HOME% (
	echo Creating cygwin home folder
	mkdir %CYGWIN_HOME%
)

echo Building download.vbs script
findstr "^::" "%~sf0" > %DOWNLOADS%\download.vbs

echo Downloading cygwin, packages and tools installer
if not exist %CYGWIN_INSTALLER% (
	cscript //Nologo %DOWNLOADER% %CYGWIN_SETUP_URL% %DOWNLOADS% %PROXY% %PROXY_USER% %PROXY_PASS%
)
if not exist %UNZIPPER% (
	cscript //Nologo %DOWNLOADER% %UNZIP_URL% %DOWNLOADS% %PROXY% %PROXY_USER% %PROXY_PASS% 
)
if not exist %PACKAGES% (
	cscript //Nologo %DOWNLOADER% %PACKAGES_URL% %DOWNLOADS% %PROXY% %PROXY_USER% %PROXY_PASS%
	RD /S /Q %PACKAGES_HOME%
	mkdir %PACKAGES_HOME%
	%UNZIPPER% -o %PACKAGES% -d %PACKAGES_HOME%
)
	
rem trick to avoid admin rights
copy %CYGWIN_INSTALLER% %DOWNLOADS%\cygwin.exe

echo Installing cygwin
%DOWNLOADS%\cygwin.exe ^
--quiet-mode ^
--local-install ^
--local-package-dir %PACKAGES_HOME% ^
--root %CYGWIN_HOME% ^
--no-shortcuts ^
--no-startmenu ^
--no-desktop 

GOTO END

:BADSYNTAX
ECHO Usage: babun.bat [/h] [/64] [/force] [/proxy=host:port[:user:pass]]
GOTO END

:INFO
ECHO.
ECHO    Name: babun.bat  
ECHO    Use this batch file to install 'babun' console
ECHO.
ECHO    Syntax: babun [/h] [/64] [/force] [/proxy=host:port] [/proxy_cred=user:pass]
ECHO.
ECHO 	'/h'	Displays the help text.
ECHO.
ECHO 	'/64'	Installs the 64-bit version of Cygwin (32-bit is the default)
ECHO.
ECHO 	'/force'	Forces download even if files are cached.
ECHO.
ECHO 	'/proxy=host:port[user:pass]'	Enables proxy host:port
ECHO.
ECHO    For example:
ECHO.
ECHO 	babun /h 
ECHO.
ECHO 	babun /64 /force /proxy=test.com:80
ECHO.
ECHO 	babun /64 /force /proxy=test.com:80:john:pass 
ECHO.
ECHO.
GOTO END

rem --------------------------
rem EMBEEDED VBS SCRIPT TRICK
rem --------------------------
::strLink = Wscript.Arguments(0)
::strSaveName = Mid(strLink, InStrRev(strLink,"/") + 1, Len(strLink))
::strSaveTo = Wscript.Arguments(1) & strSaveName
::
::WScript.Echo "Download: " & strLink
::WScript.Echo "Save to : " & strSaveTo
::
::Set objHTTP = CreateObject("Msxml2.ServerXMLHTTP.6.0")
::objHTTP.setTimeouts 30000, 30000, 30000, 30000 
::objHTTP.open "GET", strLink, False
::If WScript.Arguments.Count >= 3 Then
::	objHTTP.setProxy 2, Wscript.Arguments(2), ""
::End If
::If WScript.Arguments.Count = 5 Then
::	objHTTP.setProxyCredentials Wscript.Arguments(3), Wscript.Arguments(4)
::End If
::
::objHTTP.send
::
::Set objFSO = CreateObject("Scripting.FileSystemObject")
::If objFSO.FileExists(strSaveTo) Then
::  objFSO.DeleteFile(strSaveTo)
::End If
::
::If objHTTP.Status = 200 Then
::  Dim objStream
::  Set objStream = CreateObject("ADODB.Stream")
::  With objStream
::    .Type = 1 'adTypeBinary
::    .Open
::    .Write objHTTP.responseBody
::    .SaveToFile strSaveTo
::    .Close
::  End With
::  set objStream = Nothing
::End If
::
::If objFSO.FileExists(strSaveTo) Then
::  WScript.Echo "Download `" & strSaveName & "` completed successfuly."
::End If
::
rem SCRIPT END
:END