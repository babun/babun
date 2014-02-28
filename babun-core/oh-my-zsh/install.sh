#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"

# plugin descriptor
plugin_name=oh-my-zsh
plugin_version=1
should_install_plugin


src="$babun/external/oh-my-zsh"
dest="$babun/home/oh-my-zsh/.oh-my-zsh"

if [ ! -d "$src" ]; then
	PATH=/usr/bin git clone https://github.com/robbyrussell/oh-my-zsh.git "$src" 
fi

if [ ! -d "$dest" ]; then
	mkdir -p "$dest"
    /bin/cp -rf "$src/." "$dest"
    /bin/cp "$dest/templates/zshrc.zsh-template" "$babun/home/.zshrc"
    /bin/sed -i 's/ZSH_THEME=".*"/ZSH_THEME="kennethreitz"/' "$babun/home/.zshrc"
fi

