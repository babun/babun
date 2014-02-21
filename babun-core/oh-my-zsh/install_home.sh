#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"

src="$babun/home/oh-my-zsh"

# if oh-my-zsh not installed
if [ ! -d "$homedir/.oh-my-zsh" ]; then	
	
	# installing oh-my-zsh
    /bin/cp -rf "$src/.oh-my-zsh" "$homedir/.oh-my-zsh" 

    # fixing oh-my-zsh components
	zsh -c "source ~/.zshrc; rm -f \"$homedir/.zcompdump\"; compinit -u" &> /dev/null
	zsh -c "source ~/.zshrc; cat \"$homedir/.zcompdump\" > \"$homedir/.zcompdump-\"*" &> /dev/null
	
fi

