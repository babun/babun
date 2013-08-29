# Babun - powershell.

Install:
Click [here](https://github.com/reficio/babun/raw/master/babun.bat)  to download the babun.bat installer. 
Then just run the script in the console.

To check the syntax execute:
<pre>
$ babun.bat /h

   Name: babun.bat
   Use this batch file to install 'babun' console

   Syntax: babun [/h] [/64] [/force] [/proxy=host:port] [/proxy_cred=user:pass]
        '/h'    Displays the help text.
        '/64'   Installs the 64-bit version of Cygwin (32-bit is the default)
        '/force'        Forces download even if files are cached.
        '/proxy=host:port[user:pass]'   Enables proxy host:port

   For example:
        babun /h
        babun /64 /force /proxy=test.com:80
        babun /64 /force /proxy=test.com:80:john:pass
</pre>