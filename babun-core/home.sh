#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

homedir=~
eval homedir=$homedir

/bin/cp -rf "$babun/home/." "$homedir"

# add source .babunrc
shells=("$homedir/.bashrc" "$homedir/.zshrc")
for shell in "${shells[@]}"; do	
	if ! grep -Fxq "source ~/.babunrc" "$shell" ;then
		echo "Supplementing shell -> $shell"
		echo "source ~/.babunrc" >> "$shell"
	fi
done

# add source .bashrc.prompt
shells=("$homedir/.bashrc")
for shell in "${shells[@]}"; do	
	if ! grep -Fxq "source ~/.prompt" "$shell" ;then
		echo "Supplementing prompt -> $shell"
		echo "source ~/.prompt" >> "$shell"
	fi
done


# fixing oh-my-zsh
zsh -c "source ~/.zshrc; rm -f \"$homedir/.zcompdump\"; compinit"
zsh -c "source ~/.zshrc; cat \"$homedir/.zcompdump\" > \"$homedir/.zcompdump-\"*"