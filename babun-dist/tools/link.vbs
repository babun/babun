	set oWS = WScript.CreateObject("WScript.Shell") 
	sLinkFile = Wscript.Arguments(0) 
	set oLink = oWS.CreateShortcut(sLinkFile) 
	oLink.TargetPath = Wscript.Arguments(1)
	oLink.Arguments  = "-"
	oLink.Save 