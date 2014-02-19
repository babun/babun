#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
src="$babun/external/oh-my-zsh"
dest="$babun/home/.oh-my-zsh"

if [ ! -d "$src" ]; then
	clone="PATH=/usr/bin git clone https://github.com/robbyrussell/oh-my-zsh.git \"$src\""
	clone || echo "git clone error - repeating!"
	if ! [ $? -eq 0 ]; then clone ; fi	
fi

if [ ! -d "$dest" ]; then
    /bin/cp -rf "$src/." "$dest"
    /bin/cp "$dest/templates/zshrc.zsh-template" "$babun/home/.zshrc"
fi
