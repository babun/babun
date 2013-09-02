@echo off
setlocal enableextensions enabledelayedexpansion

:SETUP
set BABUN_VERSION=master
set CYGWIN_VERSION=x86
set PROXY=
set FORCE=false

set SCRIPT_PATH=%~dpnx0
set BABUN_HOME=%USERPROFILE%\.babun\
set DOWNLOADS=%BABUN_HOME%\downloads\
set CYGWIN_HOME=%BABUN_HOME%\cygwin\
set PACKAGES_HOME=%BABUN_HOME%\packages\
set SRC_HOME=%BABUN_HOME%\src\
set USER_AGENT=Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)

rem scripts:
set DOWNLOADER=%DOWNLOADS%\download.vbs
set LINKER=%DOWNLOADS%\link.vbs
set UNZIPPER=%DOWNLOADS%\unzip.vbs

rem to-download:
set CYGWIN_INSTALLER=%DOWNLOADS%\%CYGWIN_INSTALLER%setup-%CYGWIN_VERSION%.exe
set PACKAGES=%DOWNLOADS%\packages-%CYGWIN_VERSION%.zip
set SRC=%DOWNLOADS%\%BABUN_VERSION%.zip

set CYGWIN_SETUP_URL=http://cygwin.com/setup-%CYGWIN_VERSION%.exe
set PACKAGES_URL=https://babun.svn.cloudforge.com/packages/packages-%CYGWIN_VERSION%.zip
set SRC_URL=https://github.com/reficio/babun/archive/%BABUN_VERSION%.zip

set CYGWIN_NO_ADMIN_INSTALLER=%DOWNLOADS%\cygwin.exe
set LOG_FILE=babun.log

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
call:log "Installing babun version [%BABUN_VERSION%]"

if not exist "%BABUN_HOME%" (mkdir "%BABUN_HOME%")
if not exist "%DOWNLOADS%" (mkdir "%DOWNLOADS%")
if not exist "%CYGWIN_HOME%" (mkdir "%CYGWIN_HOME%")

if exist "%DOWNLOADS%\*.vbs" (
	del /F /Q "%DOWNLOADS%\*.vbs"
)

call:log "Extracting embeeded VBS scripts"
rem ---------------------------------
rem EMBEEDED VBS TRICK - UNZIP.VBS
rem ---------------------------------
set UNZIP_VBS=^
	set fso = CreateObject("Scripting.FileSystemObject") !N!^
	ZipFile = fso.GetAbsolutePathName(Wscript.Arguments(0)) !N!^
	ExtractTo = fso.GetAbsolutePathName(Wscript.Arguments(1)) !N!^
	If NOT fso.FolderExists(ExtractTo) Then !N!^
		fso.CreateFolder(ExtractTo) !N!^
	End If !N!^
	set objShell = CreateObject("Shell.Application") !N!^
	objShell.NameSpace(ExtractTo).CopyHere objShell.NameSpace(ZipFile).Items !N!^
	Set fso = Nothing !N!^
	Set objShell = Nothing
	
echo !UNZIP_VBS! > "%UNZIPPER%"


rem ---------------------------------
rem EMBEEDED VBS TRICK - LINK.VBS
rem ---------------------------------
set LINK_VBS=^
	set oWS = WScript.CreateObject("WScript.Shell") !N!^
	sLinkFile = Wscript.Arguments(0) !N!^
	set oLink = oWS.CreateShortcut(sLinkFile) !N!^
	oLink.TargetPath = Wscript.Arguments(1) !N!^
	oLink.Arguments  = Wscript.Arguments(2) !N!^
	oLink.Save
	
echo !LINK_VBS! > "%LINKER%"

rem ---------------------------------
rem EMBEEDED VBS TRICK - DOWNLOAD.VBS
rem ---------------------------------
set DOWNLOAD_VBS=^
	strLink = Wscript.Arguments(0)!N!^
	strSaveName = Mid(strLink, InStrRev(strLink,"/") + 1, Len(strLink)) !N!^
	strSaveTo = Wscript.Arguments(1) ^& strSaveName !N!^
	WScript.StdOut.Write "[babun] Downloading " ^& strLink !N!^
	Set objHTTP = CreateObject("Msxml2.ServerXMLHTTP.3.0") !N!^
	objHTTP.setTimeouts 30000, 30000, 30000, 30000 !N!^
	objHTTP.open "GET", strLink, False !N!^
	objHTTP.setRequestHeader "User-Agent", Wscript.Arguments(2) !N!^
	If ((WScript.Arguments.Count ^>= 4) And (Len(WScript.Arguments(3)) ^> 0)) Then !N!^
		objHTTP.setProxy 2, Wscript.Arguments(3), "" !N!^
	End If!N!^
	If ((WScript.Arguments.Count = 6) And (Len(WScript.Arguments(3)) ^> 0)) Then !N!^
		objHTTP.setProxyCredentials Wscript.Arguments(4), Wscript.Arguments(5) !N!^
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
	  WScript.Echo " [OK]" !N!^
	Else !N!^
		WScript.Echo " [FAILED]" !N!^
	End If
		
echo !DOWNLOAD_VBS! > "%DOWNLOADER%"

if not exist "%CYGWIN_INSTALLER%" (
	cscript //Nologo "%DOWNLOADER%" "%CYGWIN_SETUP_URL%" "%DOWNLOADS%" "%USER_AGENT%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"
)
if not exist "%SRC%" (
	cscript //Nologo "%DOWNLOADER%" "%SRC_URL%" "%DOWNLOADS%" "%USER_AGENT%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"
)
if not exist "%PACKAGES%" (
	cscript //Nologo "%DOWNLOADER%" "%PACKAGES_URL%" "%DOWNLOADS%" "%USER_AGENT%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"	
)

if exist "%PACKAGES_HOME%" (
	RD /S /Q "%PACKAGES_HOME%"
)
mkdir "%PACKAGES_HOME%"
call:log "Unzipping cygwin packages"
cscript //Nologo "%UNZIPPER%" "%PACKAGES%" "%PACKAGES_HOME%"	

if exist "%SRC_HOME%" (
	RD /S /Q "%SRC_HOME%"
)
mkdir "%SRC_HOME%"
call:log "Unzipping bash configuration"
cscript //Nologo "%UNZIPPER%" "%SRC%" "%SRC_HOME%"	
	
copy "%CYGWIN_INSTALLER%" "%CYGWIN_NO_ADMIN_INSTALLER%" >> %LOG_FILE% 

call:log "Installing cygwin"
"%CYGWIN_NO_ADMIN_INSTALLER%" ^
	--quiet-mode ^
	--local-install ^
	--local-package-dir %PACKAGES_HOME% ^
	--root %CYGWIN_HOME% ^
	--no-shortcuts ^
	--no-startmenu ^
	--no-desktop ^
	--packages wget > %LOG_FILE%

call:log "Tweaking shell settings"
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "[babun] Bash shell init"'
xcopy "%SRC_HOME%\babun-%BABUN_VERSION%\src\etc\*.*" "%CYGWIN_HOME%\etc" /i /s /y >> %LOG_FILE%
xcopy "%SRC_HOME%\babun-%BABUN_VERSION%\src\usr\*.*" "%CYGWIN_HOME%\usr" /i /s /y >> %LOG_FILE%
xcopy "%SRC_HOME%\babun-%BABUN_VERSION%\src\home\*.*" "%CYGWIN_HOME%\home\%username%" /i /s /y >> %LOG_FILE%
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/chmod.exe +x /usr/local/bin/bark'

call:log "Propagating proxy properties"
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "" > "%CYGWIN_HOME%\home\%username%\.babunrc"'
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export ftp_proxy=http://%PROXY_USER%:%PROXY_PASS%@%PROXY%" >> "%CYGWIN_HOME%\home\%username%\.babunrc"'
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export http_proxy=http://%PROXY_USER%:%PROXY_PASS%@%PROXY%" >> "%CYGWIN_HOME%\home\%username%\.babunrc"'

call:log "Configuring start scripts"
copy /y nul "%CYGWIN_HOME%\start.bat" >> %LOG_FILE%
echo start %CYGWIN_HOME%\bin\mintty.exe - >> "%CYGWIN_HOME%\start.bat"
del "%CYGWIN_HOME%\Cygwin*"
	
call:log "Creating desktop link"
cscript //Nologo "%LINKER%" "%USERPROFILE%\Desktop\babun.lnk" "%CYGWIN_HOME%\bin\mintty.exe" " - "

call:log "Starting babun"
start %CYGWIN_HOME%\bin\mintty.exe -

GOTO:EOF

:BADSYNTAX
ECHO Usage: babun.bat [/h] [/64] [/force] [/proxy=host:port[:user:pass]]
GOTO:EOF

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

GOTO:EOF
	
:log
	ECHO [babun] %~1
GOTO:EOF
