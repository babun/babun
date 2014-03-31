# Babun - a Windows shell you will love!

Would you like to use a linux-like console on a Windows host without a lot of fuzz? Try out babun, you will simply love it!

### Features 

#### Cygwin

The core of Babun consists of a pre-installed Cygwin. Cygwin is a great tool, but there's a lot of quirks and tricks that makes you loose a lot of time to make it actually "usable". Not only babun solves most of these problems, but also contains a lot of vital packages, so that you can be productive from the very first minute. 

#### Package manager

Babun provides a package manager called 'pact'. It is similar to 'apt-get' or 'yum'. Pact enables you to install/search/upgrade and deinstall cygwin packages with no hassle at all. Just invoke 'pact --help' to check how to use it.

#### Shell

Babun's shell is tweaked in order to provide the best possible user-experience. There are two shell types that are pre-configured and avaiable right away - bash and zsh (the default one). Babun's shell provides syntax highlighting, unix tools, software development tools or tiny custom scripts and aliases to make your life easier.

#### Console

Mintty is the console used in babun. It features an xterm-256 mode, nice fonts and simply looks great!

#### Proxying

Babun supports HTTP proxies out of the box. Just add the address and the credentials of your HTTP proxy server to the .babun.rc file located in your home folder and execute 'source .babunrc' to enable HTTP proxying. SOCKS proxies are not supported for now.

#### Developer tools

Babun features many packages, convenience tools and scripts that make your life much easier. The long list of features includes:
* programming languages (python, perl, groovy, etc.)
* git (with a wide variety of aliases and tweaks)
* unix tools (grep, wget, curl, etc.)
* oh-my-zsh
* custom scripts (pbcopy, pbpaste, babun, etc.)

#### Plugin architecture

Babun has a very small microkernel (cygwin, a couple of bash scripts and a bit of a convention) and a plugin architecture on the top of it - which means that almost everything is a plugin. 

#### Auto-update

Self-update is at the very heart of babun! 

Many Cygwin tools are simple bash scripts - once you install them there is no chance of getting the newer version in a smooth way. You either delete the older version or overwrite it with the newest one loosing all the changes you have made in between.

Babun contains an auto-update feature which enables updating both the microkernel and the plugins. Files located in your home folder will not be delted nor overwritten which preserves your cusomizations.

#### Installer

Babun features a silent command-line installation script that may be executed without Admin rights.

### Installation

Just download the dist file from TODO, unzip it and run the install.bat script.
It's as simple as it gets!

### Project Sturcture


## Contributors

We are looking for new contributors, so if you fancy bash progamming and if you would like to contribute a patch or a code up a new plugin give us a shout!


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/reficio/babun/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

