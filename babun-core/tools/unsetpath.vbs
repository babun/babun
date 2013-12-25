	' ignore if no argument was passed to the script
	if (WScript.Arguments.Count >= 1) Then
		path = Wscript.Arguments(0)
		pathWithSeparator = ";" & babunPath
		Set WshShell = WScript.CreateObject("WScript.Shell")
		Set WshEnv = WshShell.Environment("USER")
		userPath = WshEnv("Path")
		' check if path exists in the user path
		unsetPath = userPath
		if InStr(1, userPath, path) > 0 Then
			' remove path from user path
			unsetPath = Replace(unsetPath, pathWithSeparator, "")
			unsetPath = Replace(unsetPath, path, "")
			WshEnv("Path") = unsetPath
		End If
	End If  
