@echo off
setlocal enableextensions enabledelayedexpansion

:SETUP
set BABUN_VERSION=master
set CYGWIN_VERSION=x86
set PROXY=
set NOCACHE=false

set SCRIPT_PATH=%~dpnx0
set BABUN_HOME=%USERPROFILE%\.babun
set DOWNLOADS=%BABUN_HOME%\downloads
set CYGWIN_HOME=%BABUN_HOME%\cygwin
set PACKAGES_HOME=%BABUN_HOME%\packages
set SCRIPTS_HOME=%BABUN_HOME%\scripts
set SRC_HOME=%BABUN_HOME%\src
set USER_AGENT=Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)

rem scripts:
set DOWNLOADER=%SCRIPTS_HOME%\download.vbs
set LINKER=%SCRIPTS_HOME%\link.vbs
set UNZIPPER=%SCRIPTS_HOME%\unzip.vbs
set PATHSETTER=%SCRIPTS_HOME%\setpath.vbs
set PATHUNSETTER=%SCRIPTS_HOME%\unsetpath.vbs

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
IF '%1'=='/h' GOTO USAGE 
IF '%1'=='/?' GOTO USAGE
if '%1'=='/install' GOTO INSTALL
IF '%1'=='/uninstall' GOTO UNINSTALL
IF '%1'=='/64' GOTO VERSION64
IF '%1'=='/nocache' GOTO NOCACHE
IF '%1'=='/user-agent' GOTO AGENT
IF '%1'=='/proxy' GOTO PROXY
IF '%1'=='' (GOTO BEGIN) ELSE (GOTO BADSYNTAX)
REM Done checking command line for switches
GOTO BEGIN

	:VERSION64
	SET CYGWIN_VERSION=x86_64
	SHIFT
	GOTO CHECKFORSWITCHES

	:NOCACHE
	SET NOCACHE=true
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
			set PROXY_HOST=%array[0]%
			set PROXY_PORT=%array[1]%
		)
		if [%array[2]%] NEQ  [] (
			if [%array[3]%] == [] (GOTO :BADSYNTAX)
			set PROXY_USER=%array[2]%
			set PROXY_PASS=%array[3]%
		)
	SHIFT
	SHIFT
	GOTO CHECKFORSWITCHES
	
	:AGENT
	set USER_AGENT=%~2
	SHIFT
	SHIFT
	GOTO CHECKFORSWITCHES
		
:BEGIN
if exist "%CYGWIN_HOME%\bin\mintty.exe" goto RUN

:INSTALL
if %ERRORLEVEL% NEQ 0 (GOTO ERROR)	
ECHO [babun] Installing babun version [%BABUN_VERSION%]

rem goto PROPAGATE

if not exist "%BABUN_HOME%" (mkdir "%BABUN_HOME%" || goto :ERROR)
if not exist "%DOWNLOADS%" (mkdir "%DOWNLOADS%" || goto :ERROR)
if not exist "%CYGWIN_HOME%" (mkdir "%CYGWIN_HOME%" || goto :ERROR)

if '%NOCACHE%'=='true' (
 	ECHO [babun] Forcing download as /nocache switch specified
 	del /F /Q "%DOWNLOADS%\*.*" || goto :ERROR
)

if exist "%SCRIPTS_HOME%" (
	RD /S /Q "%SCRIPTS_HOME%" || goto :ERROR
)
mkdir "%SCRIPTS_HOME%"

ECHO [babun] Extracting embeeded VBS scripts
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
	
echo !UNZIP_VBS! > "%UNZIPPER%" || goto :ERROR

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
	
echo !LINK_VBS! > "%LINKER%" || goto :ERROR

rem ---------------------------------
rem EMBEEDED VBS TRICK - DOWNLOAD.VBS
rem ---------------------------------
set DOWNLOAD_VBS=^
	strLink = Wscript.Arguments(0)!N!^
	strSaveName = Mid(strLink, InStrRev(strLink,"/") + 1, Len(strLink)) !N!^
	strSaveTo = Wscript.Arguments(1) ^& strSaveName !N!^
	WScript.StdOut.Write "[babun] Downloading " ^& strLink ^& " "!N!^
	Set objHTTP = Nothing !N!^
	If ((WScript.Arguments.Count ^>= 4) And (Len(WScript.Arguments(3)) ^> 0)) Then !N!^
		Set objHTTP = CreateObject("Msxml2.ServerXMLHTTP.6.0") !N!^
	Else !N!^
		Set objHTTP = CreateObject("Msxml2.ServerXMLHTTP.3.0") !N!^
	End If !N!^
	objHTTP.setTimeouts 120000, 120000, 120000, 120000 !N!^
	objHTTP.open "GET", strLink, False !N!^
	If (Len(WScript.Arguments(2)) ^> 0) Then!N!^
	  objHTTP.setRequestHeader "User-Agent", Wscript.Arguments(2) !N!^
	End If !N!^
	If ((WScript.Arguments.Count ^>= 4) And (Len(WScript.Arguments(3)) ^> 0)) Then !N!^
		objHTTP.setProxy 2, Wscript.Arguments(3), "" !N!^
	End If!N!^
	If ((WScript.Arguments.Count = 6) And (Len(WScript.Arguments(3)) ^> 0)) Then !N!^
		If ((Len(WScript.Arguments(4)) ^> 0) And (Len(WScript.Arguments(5)) ^> 0)) Then !N!^
			objHTTP.setProxyCredentials Wscript.Arguments(4), Wscript.Arguments(5) !N!^
		End If!N!^
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
	  WScript.Echo "[OK]" !N!^
	Else !N!^
		WScript.Echo "[FAILED]" !N!^
	End If
		
echo !DOWNLOAD_VBS! > "%DOWNLOADER%" || goto :ERROR

rem ---------------------------------
rem EMBEEDED VBS TRICK - SETPATH.VBS
rem ---------------------------------
set SETPATH_VBS=^
	' ignore if no argument was passed to the script!N!^
	if (WScript.Arguments.Count ^>= 1) Then!N!^
		path = Wscript.Arguments(0)!N!^
		Set WshShell = WScript.CreateObject("WScript.Shell")!N!^
		Set WshEnv = WshShell.Environment("USER")!N!^
		userPath = WshEnv("Path")!N!^
		' check if path does not already exists in the user path!N!^
		if InStr(1, userPath, path) ^= 0 Then!N!^
			' check if path is not empty!N!^
			if Len(userPath) Then!N!^
				path = ";" ^& path!N!^
			End If!N!^
			' set the path!N!^
			WshEnv("Path") = WshEnv("Path") ^& path!N!^
		End If!N!^
	End If
	
echo !SETPATH_VBS! > "%PATHSETTER%" || goto :ERROR


rem ---------------------------------
rem EMBEEDED VBS TRICK - UNSETPATH.VBS
rem ---------------------------------
set UNSETPATH_VBS=^
	' ignore if no argument was passed to the script!N!^
	if (WScript.Arguments.Count ^>= 1) Then!N!^
		path = Wscript.Arguments(0)!N!^
		pathWithSeparator = ";" ^& babunPath!N!^
		Set WshShell = WScript.CreateObject("WScript.Shell")!N!^
		Set WshEnv = WshShell.Environment("USER")!N!^
		userPath = WshEnv("Path")!N!^
		' check if path exists in the user path!N!^
		unsetPath = userPath
		if InStr(1, userPath, path) ^> 0 Then!N!^
			' remove path from user path!N!^
			unsetPath = Replace(unsetPath, pathWithSeparator, "")!N!^
			unsetPath = Replace(unsetPath, path, "")!N!^
			WshEnv("Path") = unsetPath!N!^
		End If!N!^
	End If
	
echo !UNSETPATH_VBS! > "%PATHUNSETTER%" || goto :ERROR

if not exist "%CYGWIN_INSTALLER%" (
	cscript //Nologo "%DOWNLOADER%" "%CYGWIN_SETUP_URL%" "%DOWNLOADS%" "%USER_AGENT%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"
	if not exist "%CYGWIN_INSTALLER%" (GOTO ERROR)
)
if not exist "%SRC%" (
	cscript //Nologo "%DOWNLOADER%" "%SRC_URL%" "%DOWNLOADS%" "%USER_AGENT%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"
	if not exist "%SRC%" (GOTO ERROR)
)
if not exist "%PACKAGES%" (
	cscript //Nologo "%DOWNLOADER%" "%PACKAGES_URL%" "%DOWNLOADS%" "%USER_AGENT%" "%PROXY%" "%PROXY_USER%" "%PROXY_PASS%"	
	if not exist "%PACKAGES%" (GOTO ERROR)
)

if exist "%PACKAGES_HOME%" (
	RD /S /Q "%PACKAGES_HOME%" || goto :ERROR
)
mkdir "%PACKAGES_HOME%"
ECHO [babun] Extracting binary packages
cscript //Nologo "%UNZIPPER%" "%PACKAGES%" "%PACKAGES_HOME%"	
if not exist "%PACKAGES_HOME%/*.*" (GOTO ERROR)

if exist "%SRC_HOME%" (
	RD /S /Q "%SRC_HOME%" || goto :ERROR
)
mkdir "%SRC_HOME%"
ECHO [babun] Extracting bash configuration
cscript //Nologo "%UNZIPPER%" "%SRC%" "%SRC_HOME%"	
if not exist "%SRC_HOME%/*.*" (GOTO ERROR)
	
copy "%CYGWIN_INSTALLER%" "%CYGWIN_NO_ADMIN_INSTALLER%" >> %LOG_FILE% || goto :ERROR

ECHO [babun] Installing cygwin
"%CYGWIN_NO_ADMIN_INSTALLER%" ^
	--quiet-mode ^
	--local-install ^
	--local-package-dir %PACKAGES_HOME% ^
	--root %CYGWIN_HOME% ^
	--no-shortcuts ^
	--no-startmenu ^
	--no-desktop ^
	--packages cron,shutdown,openssh,ncurses,vim,nano,unzip,curl,rsync,ping,links,wget,httping,time > %LOG_FILE%
if %ERRORLEVEL% NEQ 0 (GOTO ERROR)	
	
:PROPAGATE		
ECHO [babun] Tweaking shell settings
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "[babun] Bash shell init"' || goto :ERROR
xcopy "%SRC_HOME%\babun-%BABUN_VERSION%\src\etc\*.*" "%CYGWIN_HOME%\etc" /i /s /y >> %LOG_FILE% || goto :ERROR
xcopy "%SRC_HOME%\babun-%BABUN_VERSION%\src\usr\*.*" "%CYGWIN_HOME%\usr" /i /s /y >> %LOG_FILE% || goto :ERROR
xcopy "%SRC_HOME%\babun-%BABUN_VERSION%\src\home\*.*" "%CYGWIN_HOME%\home\%username%" /i /s /y >> %LOG_FILE% || goto :ERROR
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/chmod.exe +x /usr/local/bin/bark' || goto :ERROR

ECHO [babun] Propagating babun properties
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "# Do not modify this file. It will be overwritten." > "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR

set PROXYBASH=
set PROXY_JAVAOPTS=
IF NOT "%PROXY%"=="" IF NOT "%PROXY_USER%"=="" IF NOT "%PROXY_PASS%"==""  (	
	set PROXYBASH=http://%PROXY_USER%:%PROXY_PASS%@%PROXY%
	set PROXY_JAVAOPTS=-Dhttp.proxyHost=%PROXY_HOST% -Dhttp.proxyPort=%PROXY_PORT%
)
IF NOT "%PROXY%"=="" IF "%PROXY_USER%"=="" IF "%PROXY_PASS%"==""  (	
	set PROXYBASH=http://%PROXY%
	set PROXY_JAVAOPTS=%PROXY_JAVA_OPTS% -Dhttp.proxyUser=%PROXY_USER% -Dhttp.proxyPassword=%PROXY_PASS%
)
IF NOT "%PROXYBASH%"=="" (
	ECHO [babun] Propagating proxy properties [%PROXYBASH%]
	"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export http_proxy=\"%PROXYBASH%\"" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
	"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export https_proxy=\$http_proxy" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
	rem "%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export ftp_proxy=\$http_proxy" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
	"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export rsync_proxy=\$http_proxy" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
	"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export no_proxy=\"localhost,127.0.0.1,localaddress\"" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
)
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export cygwin_version=\"%CYGWIN_VERSION%\"" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export babun_version=\"%BABUN_VERSION%\"" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
"%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export user_agent=\"%USER_AGENT%\"" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR

rem "%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export JAVA_OPTS=\"%PROXY_JAVAOPTS% -Xms128m -Xmx512m\"" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
rem "%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export MAVEN_OPTS=\$JAVA_OPTS" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
rem "%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export ANT_OPTS=\$JAVA_OPTS" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
rem "%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "export GRADLE_OPTS=\$JAVA_OPTS" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR
rem "%CYGWIN_HOME%\bin\bash.exe" -c '/bin/echo.exe "alias java=\"java $JAVA_OPTS \"" >> "%CYGWIN_HOME%\home\%username%\.babunrc" ' || goto :ERROR

ECHO [babun] Configuring start scripts
copy /y nul "%CYGWIN_HOME%\start.bat" >> %LOG_FILE% || goto :ERROR
echo start %CYGWIN_HOME%\bin\mintty.exe - >> "%CYGWIN_HOME%\start.bat" || goto :ERROR
if exist "%CYGWIN_HOME%\Cygwin*" (
	del "%CYGWIN_HOME%\Cygwin*" || goto :ERROR
)
	
ECHO [babun] Creating desktop link
cscript //Nologo "%LINKER%" "%USERPROFILE%\Desktop\babun.lnk" "%CYGWIN_HOME%\bin\mintty.exe" " - "
if not exist "%USERPROFILE%\Desktop\babun.lnk" (GOTO ERROR)

ECHO [babun] Setting path
cscript //Nologo "%PATHSETTER%" "%SRC_HOME%\babun-%BABUN_VERSION%"

:RUN
ECHO [babun] Starting babun
start %CYGWIN_HOME%\bin\mintty.exe - || goto :ERROR

GOTO END

:UNINSTALL
ECHO [babun] Uninstalling...
if not exist "%BABUN_HOME%" (
	echo [babun] Not installed
	GOTO END
) 
if exist "%PATHUNSETTER%" (
	echo [babun] Removing path...
	cscript //Nologo "%PATHUNSETTER%" "%SRC_HOME%\babun-%BABUN_VERSION%" || goto :ERROR
)
echo [babun] Deleting files...
RD /S /Q "%BABUN_HOME%" || goto :ERROR
if exist "%USERPROFILE%\Desktop\babun.lnk" (
  del "%USERPROFILE%\Desktop\babun.lnk" || goto :ERROR
)
GOTO END

:BADSYNTAX
ECHO Usage: babun.bat [/h] [/nocache] [/proxy=host:port[:user:pass]] [/64] [/uninstall]
GOTO END

:USAGE
ECHO.
ECHO    Syntax:
ECHO		babun	[/h] [/?] [/64] [/nocache] [/install] [/uninstall]
ECHO			[/proxy=host:port[:user:pass]] [/user-agent=agent-string]  !N!
ECHO    Default behavior if no option passed:
ECHO   	* install -^> if babun IS NOT installed
ECHO   	* start -^> if babun IS installed
ECHO.
ECHO    Options:
ECHO 	'/?' or '/h' 	Displays the help text
ECHO 	'/nocache'	Forces download even if files are downloaded
ECHO 	'/64'		Marks to download the 64-bit version of Cygwin (NOT RECOMMENDED) 
ECHO 	'/install'	Installs babun; forces the reinstallation even if already installed  
ECHO 	'/uninstall'	Uninstalls babun; option is exclusive, others are ignored  
ECHO 	'/user-agent=agent-string'	Identify as agent-string to the http server
ECHO 	'/proxy=host:port[user:pass]'	Enables HTTP proxy host:port 
ECHO.
ECHO    For example: 
ECHO 	babun /? 
ECHO 	babun /nocache /proxy=test.com:80 /install 
ECHO 	babun /install /user-agent="Mozilla/5.0 (Windows NT 6.1; rv:6.0)" 
ECHO.
GOTO END

:ERROR
ECHO Terminating due to error #%errorlevel%
EXIT /b %errorlevel%

:END
