	set oWS = WScript.CreateObject("WScript.Shell") 
	sLinkFile = Wscript.Arguments(0) 
	set oLink = oWS.CreateShortcut(sLinkFile) 
	oLink.TargetPath = "cmd" 
	oLink.Arguments  = "/c " + chr(34) + Wscript.Arguments(1) + + chr(34)
	oLink.Save  
