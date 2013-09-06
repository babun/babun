# Babun - windows shell you will love!

Install:
Click [here](https://github.com/reficio/babun/raw/master/babun.bat)  to download the babun.bat installer. Then just run the script in the console.

__Make sure to use the /proxy switch if you are behind a corporate firewall/proxy!__

What is so cool about babun:
* it is a pre-bundled and tweaked cygwin console
* it can be installed without admin rights on Windows computers
* it provides a linux-like package manager called bark
* it provides a xterm-256 compatible console
* it natively supports HTTP proxying (installer and the console)
* it provides an automatic, silent command-line installer
* it is mega cool :)

To check the syntax execute:
<pre>
$ babun.bat /h

   Syntax:
        babun   [/h] [/?] [/64] [/nocache] [/install] [/uninstall]
                [/proxy=host:port[:user:pass]] [/user-agent=agent-string]

   Default behavior if no option passed:
        * install -> if babun IS NOT installed
        * start -> if babun IS installed

   Options:
        '/?' or '/h'    Displays the help text.
        '/nocache'      Forces download even if files are downloaded.
        '/64'           Marks to download the 64-bit version of Cygwin (NOT RECOMMENDED)
        '/install'      Installs babun; forces the reinstallation even if already installed
        '/uninstall'    Uninstalls babun, option is exclusive, others are ignored
        '/user-agent=agent-string'      Identify as agent-string to the http server.
        '/proxy=host:port[user:pass]'   Enables HTTP proxy host:port

   For example:
        babun /?
        babun /nocache /proxy=test.com:80 /install
        babun /install /user-agent="Mozilla/5.0 (Windows NT 6.1; rv:6.0)"
</pre>

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/reficio/babun/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

