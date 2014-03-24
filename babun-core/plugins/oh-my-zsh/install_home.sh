#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"

src="$babun/home/oh-my-zsh"

if [ ! -d "$homedir/.oh-my-zsh" ]; then		
    git --git-dir="$src/.oh-my-zsh/.git" --work-tree="$src/.oh-my-zsh" reset --hard
    # installing oh-my-zsh
    /bin/cp -rf "$src/.oh-my-zsh" "$homedir/.oh-my-zsh" 	    

    # setting zsh as the default shell    	
    if grep -q "/bin/bash" "/etc/passwd"; then
   		sed -i 's/\/bin\/bash/\/bin\/zsh/' "/etc/passwd"
 	fi
fi


if [ ! -f "$homedir/.zshrc" ]; then
	/bin/cp "$babun/home/.zshrc" "$homedir/.zshrc" 

	# fixing oh-my-zsh components
	zsh -c "source ~/.zshrc; rm -f \"$homedir/.zcompdump\"; compinit -u" &> /dev/null
	zsh -c "source ~/.zshrc; cat \"$homedir/.zcompdump\" > \"$homedir/.zcompdump-\"*" &> /dev/null	
fi

