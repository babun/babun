# Babun - windows shell you will love!

Install:
Click [here](https://github.com/reficio/babun/raw/master/babun.bat)  to download the babun.bat installer. Then just run the script in the console.

__Make sure to use the /proxy switch if you are behind a corporate firewall!__

What is so cool about babun:
* it is a bundled and tweaked cygwin console
* it can be installed without admin rights on Windows computers
* it provides a linux-like package manager called bark (IN-PROGRESS)
* it provides a xterm-256 compatible console
* it provides an automatic, silent command-line installer
* it is mega cool :)

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

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/reficio/babun/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

