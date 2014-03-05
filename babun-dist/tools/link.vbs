	set oWS = WScript.CreateObject("WScript.Shell") 
	sLinkFile = Wscript.Arguments(0) 
	set oLink = oWS.CreateShortcut(sLinkFile) 
	oLink.TargetPath = "cmd" 
	oLink.Arguments  = "/c "+Wscript.Arguments(1)
	oLink.Save  
