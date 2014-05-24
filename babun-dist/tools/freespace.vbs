	' ignore if no argument was passed to the script
	if (WScript.Arguments.Count >= 1) Then
		drive = Wscript.Arguments(0)
		Set objWMIService = GetObject("winmgmts:")
		Set objLogicalDisk = objWMIService.Get("Win32_LogicalDisk.DeviceID='"+drive+"'")
		Wscript.Echo objLogicalDisk.FreeSpace
	End If  