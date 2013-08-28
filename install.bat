rem @echo off
setlocal enableextensions enabledelayedexpansion

set CYGWIN_VERSION=x86
set BABUN_VERSION=master

set BABUN_HOME=%USERPROFILE%\.babun\
set DOWNLOADS=%BABUN_HOME%\downloads\
set CYGWIN_HOME=%BABUN_HOME%\cygwin\
set PACKAGES_HOME=%BABUN_HOME%\packages\

set DOWNLOADER=%DOWNLOADS%\download.vbs
set UNZIPPER=%DOWNLOADS%\unzip.exe
set CYGWIN_INSTALLER=setup-%CYGWIN_VERSION%.exe

set CYGWIN_SETUP_URL=http://cygwin.com/setup-%CYGWIN_VERSION%.exe
set PACKAGES_URL=https://github.com/reficio/babun/archive/%BABUN_VERSION%.zip
set UNZIP_URL=http://stahlworks.com/dev/unzip.exe

echo "Creating Babun home folder"
mkdir %BABUN_HOME%

echo "Creating downloads home folder"
mkdir %DOWNLOADS%

echo "Creating cygwin home folder"
mkdir %CYGWIN_HOME%

echo "Creating packages home folder"
mkdir %PACKAGES_HOME%

:strLink = Wscript.Arguments(0)
:strSaveName = Mid(strLink, InStrRev(strLink,"/") + 1, Len(strLink))
:strSaveTo = Wscript.Arguments(1) & strSaveName
:
:WScript.Echo "HTTPDownload"
:WScript.Echo "-------------"
:WScript.Echo "Download: " & strLink
:WScript.Echo "Save to:  " & strSaveTo
:
:' Create an HTTP object
:Set objHTTP = CreateObject("Msxml2.ServerXMLHTTP.3.0")
:objHTTP.setOption 2, 13056
:
:' Download the specified URL
:
:objHTTP.open "GET", strLink, False
:objHTTP.send
:WScript.Echo "Save to:  " & objHTTP.Status
:Set objFSO = CreateObject("Scripting.FileSystemObject")
:If objFSO.FileExists(strSaveTo) Then
:  objFSO.DeleteFile(strSaveTo)
:End If
:WScript.Echo objHTTP.Status
:If objHTTP.Status = 200 Then
:  Dim objStream
:  Set objStream = CreateObject("ADODB.Stream")
:  With objStream
:    .Type = 1 'adTypeBinary
:    .Open
:    .Write objHTTP.responseBody
:    .SaveToFile strSaveTo
:    .Close
:  End With
:  set objStream = Nothing
:End If
:
:If objFSO.FileExists(strSaveTo) Then
:  WScript.Echo "Download `" & strSaveName & "` completed successfuly."
:End If

echo "Building download.vbs script"
findstr "^:" "%~sf0" > %DOWNLOADS%\download.vbs

echo "Downloading cygwin, packages and tools installer"
cscript //Nologo %DOWNLOADER% %PACKAGES_URL% %DOWNLOADS% 
cscript //Nologo %DOWNLOADER% %CYGWIN_SETUP_URL% %DOWNLOADS% 
cscript //Nologo %DOWNLOADER% %UNZIP_URL% %DOWNLOADS% 

rem trick to avoid admin rights
ren %CYGWIN_INSTALLER% cygwin.exe
del %CYGWIN_INSTALLER%

rem UNZIPPER -o %DOWNLOADS%\packages-%CYGWIN_VERSION%.zip -d %PACKAGES_HOME%

echo "Installing cygwin"
rem %DOWNLOADS%\cygwin.exe ^
--quiet-mode ^
--local-install ^
--local-package-dir %PACKAGES_HOME% ^
--root %CYGWIN_HOME% ^
--no-shortcuts ^
--no-startmenu ^
--no-desktop ^
