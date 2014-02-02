	' ignore if no argument was passed to the script
	if (WScript.Arguments.Count >= 1) Then
		path = Wscript.Arguments(0)
		Set WshShell = WScript.CreateObject("WScript.Shell")
		Set WshEnv = WshShell.Environment("USER")
		userPath = WshEnv("Path")
		' check if path does not already exists in the user path
		if InStr(1, userPath, path) = 0 Then
			' check if path is not empty
			if Len(userPath) Then
				path = ";" & path
			End If
			' set the path
			WshEnv("Path") = WshEnv("Path") & path
		End If
	End If  
