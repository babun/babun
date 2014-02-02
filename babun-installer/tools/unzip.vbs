	set fso = CreateObject("Scripting.FileSystemObject") 
	ZipFile = fso.GetAbsolutePathName(Wscript.Arguments(0)) 
	ExtractTo = fso.GetAbsolutePathName(Wscript.Arguments(1)) 
	If NOT fso.FolderExists(ExtractTo) Then 
		fso.CreateFolder(ExtractTo) 
	End If 
	set objShell = CreateObject("Shell.Application") 
	objShell.NameSpace(ExtractTo).CopyHere objShell.NameSpace(ZipFile).Items 
	Set fso = Nothing 
	Set objShell = Nothing  
