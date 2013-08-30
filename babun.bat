@echo off
setlocal enableextensions enabledelayedexpansion

:SETUP
set CYGWIN_VERSION=x86
set PROXY=
set FORCE=false

set SCRIPT_PATH=%~dpnx0
set BABUN_HOME=%USERPROFILE%\.babun\
set DOWNLOADS=%BABUN_HOME%\downloads\
set CYGWIN_HOME=%BABUN_HOME%\cygwin\
set PACKAGES_HOME=%BABUN_HOME%\packages\
set CONSOLE2_HOME=%BABUN_HOME%\Console2\

set DOWNLOADER=%DOWNLOADS%\download.vbs
set LINKER=%DOWNLOADS%\link.vbs
set UNZIPPER=%DOWNLOADS%\unzip.exe
set CYGWIN_INSTALLER=%DOWNLOADS%\%CYGWIN_INSTALLER%setup-%CYGWIN_VERSION%.exe
set CYGWIN_NO_ADMIN_INSTALLER=%DOWNLOADS%\cygwin.exe
set PACKAGES=%DOWNLOADS%\packages-%CYGWIN_VERSION%.zip
set CONSOLE2_ZIP=%DOWNLOADS%\Console-2.00b148-Beta_32bit.zip
set CONSOLE2=%CONSOLE2_HOME%\Console.exe

set CYGWIN_SETUP_URL=http://cygwin.com/setup-%CYGWIN_VERSION%.exe
set PACKAGES_URL=https://babun.svn.cloudforge.com/packages/packages-%CYGWIN_VERSION%.zip
set UNZIP_URL=http://stahlworks.com/dev/unzip.exe
set CONSOLE2_URL=http://freefr.dl.sourceforge.net/project/console/console-devel/2.00/Console-2.00b148-Beta_32bit.zip
set CONSOLE2_SETTINGS_URL=https://raw.github.com/reficio/babun/master/src/console.xml

:CONSTANTS
rem there have to be TWO EMPTY LINES after this declaration!!!
rem -----------------------------------------------------------
set N=^


rem -----------------------------------------------------------

:CHECKFORSWITCHES
IF '%1'=='/h' GOTO INFO
IF '%1'=='/64' GOTO VERSION64
IF '%1'=='/force' GOTO FORCE
IF '%1'=='/proxy' GOTO PROXY
IF '%1'=='' (GOTO BEGIN) ELSE (GOTO BADSYNTAX)
REM Done checking command line for switches
GOTO BEGIN
	:VERSION64
	SET CYGWIN_VERSION=x86_64
	SHIFT
	GOTO CHECKFORSWITCHES

	:FORCE
	SET FORCE=true
	SHIFT
	GOTO CHECKFORSWITCHES

	:PROXY
	set line=%2
		set i=0
		rem fetch proxy tokens to an array
		:PROXYTOKEN
		for /f "tokens=1* delims=:" %%a in ("!line!") do (		
			set array[!i!]=%%a
			set /A i+=1	
			set line=%%b
			if not "%line%" == "" goto :PROXYTOKEN
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


:BEGIN
echo version=%CYGWIN_VERSION%
echo force=%FORCE%
echo proxy_host=%PROXY%
echo proxy_user=%PROXY_USER%
echo proxy_pass=%PROXY_PASS%
echo.

if not exist "%BABUN_HOME%" (mkdir "%BABUN_HOME%")
if not exist "%DOWNLOADS%" (mkdir "%DOWNLOADS%")
if not exist "%CYGWIN_HOME%" (mkdir "%CYGWIN_HOME%")

echo Building embeeded scripts
rem ---------------------------------
rem EMBEEDED VBS TRICK - LINK.VBS
rem ---------------------------------
set LINK_VBS=^
	set oWS = WScript.CreateObject("WScript.Shell") !N!^
	sLinkFile = Wscript.Arguments(0) !N!^
	set oLink = oWS.CreateShortcut(sLinkFile) !N!^
	oLink.TargetPath = Wscript.Arguments(1) !N!^
	oLink.Save
	
echo !LINK_VBS! > "%LINKER%"

rem ---------------------------------
rem EMBEEDED VBS TRICK - DOWNLOAD.VBS
rem ---------------------------------
set DOWNLOAD_VBS=^
	strLink = Wscript.Arguments(0)!N!^
	strSaveName = Mid(strLink, InStrRev(strLink,"/") + 1, Len(strLink)) !N!^
	strSaveTo = Wscript.Arguments(1) ^& strSaveName !N!^
	WScript.Echo "Download: " ^& strLink !N!^
	WScript.Echo "Save to : " ^& strSaveTo !N!^
	Set objHTTP = CreateObject("Msxml2.ServerXMLHTTP.6.0") !N!^
	objHTTP.setTimeouts 30000, 30000, 30000, 30000 !N!^
	objHTTP.open "GET", strLink, False !N!^
	If WScript.Arguments.Count ^>= 3 Then !N!^
		objHTTP.setProxy 2, Wscript.Arguments(2), "" !N!^
	End If!N!^
	If WScript.Arguments.Count = 5 Then!N!^
		objHTTP.setProxyCredentials Wscript.Arguments(3), Wscript.Arguments(4)!N!^
	End If!N!^
	objHTTP.send!N!^
	Set objFSO = CreateObject("Scripting.FileSystemObject")!N!^
	If objFSO.FileExists(strSaveTo) Then!N!^
	  objFSO.DeleteFile(strSaveTo)!N!^
	End If!N!^
	If objHTTP.Status = 200 Then!N!^
	  Dim objStream!N!^
	  Set objStream = CreateObject("ADODB.Stream")!N!^
	  With objStream!N!^
		.Type = 1 'adTypeBinary!N!^
		.Open!N!^
		.Write objHTTP.responseBody!N!^
		.SaveToFile strSaveTo!N!^
		.Close!N!^
	  End With!N!^
	  set objStream = Nothing!N!^
	End If!N!^
	If objFSO.FileExists(strSaveTo) Then!N!^
	  WScript.Echo "Download completed successfuly."!N!^
	End If
		
echo !DOWNLOAD_VBS! > "%DOWNLOADER%"

echo Downloading cygwin, console2, packages and tools
if not exist "%CYGWIN_INSTALLER%" (
	cscript //Nologo "%DOWNLOADER%" "%CYGWIN_SETUP_URL%" "%DOWNLOADS%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"
)
if not exist "%UNZIPPER%" (
	cscript //Nologo "%DOWNLOADER%" "%UNZIP_URL%" "%DOWNLOADS%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"
)
if not exist "%CONSOLE2_ZIP%" (
	cscript //Nologo "%DOWNLOADER%" "%CONSOLE2_URL%" "%DOWNLOADS%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"
	"%UNZIPPER%" -o "%CONSOLE2_ZIP%" -d %BABUN_HOME%
	cscript //Nologo "%DOWNLOADER%" "%CONSOLE2_SETTINGS_URL%" "%CONSOLE2_HOME%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"	
	copy 
)
if not exist "%PACKAGES%" (
	cscript //Nologo "%DOWNLOADER%" "%PACKAGES_URL%" "%DOWNLOADS%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"
	RD /S /Q "%PACKAGES_HOME%"
	mkdir "%PACKAGES_HOME%"
	"%UNZIPPER%" -o "%PACKAGES%" -d %PACKAGES_HOME%		
)
	
echo Installing cygwin
copy "%CYGWIN_INSTALLER%" "%CYGWIN_NO_ADMIN_INSTALLER%"

echo Installing cygwin
"%CYGWIN_NO_ADMIN_INSTALLER%" ^
	--quiet-mode ^
	--local-install ^
	--local-package-dir %PACKAGES_HOME% ^
	--root %CYGWIN_HOME% ^
	--no-shortcuts ^
	--no-startmenu ^
	--no-desktop ^
	--packages wget

echo Creating desktop link
csc	ript //Nologo "%LINKER%" "%USERPROFILE%\Desktop\babun.lnk" "%CONSOLE2%"

echo Starting babun
start "%CONSOLE2%"

echo Enjoy...
GOTO END

:BADSYNTAX
ECHO Usage: babun.bat [/h] [/64] [/force] [/proxy=host:port[:user:pass]]
GOTO END

:INFO
ECHO.
ECHO    Name: babun.bat  
ECHO    Use this batch file to install 'babun' console !N!
ECHO    Syntax: babun [/h] [/64] [/force] [/proxy=host:port] [/proxy_cred=user:pass] !N!
ECHO 	'/h'	Displays the help text. !N!
ECHO 	'/64'	Installs the 64-bit version of Cygwin (32-bit is the default) !N!
ECHO 	'/force'	Forces download even if files are cached. !N!
ECHO 	'/proxy=host:port[user:pass]'	Enables proxy host:port !N!
ECHO    For example: !N!
ECHO 	babun /h !N!
ECHO 	babun /64 /force /proxy=test.com:80 !N!
ECHO 	babun /64 /force /proxy=test.com:80:john:pass !N!
ECHO.
GOTO END

:END
