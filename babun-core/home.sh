#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

homedir=~
eval homedir=$homedir

/bin/cp -rf "$babun/home/." "$homedir"

shells=("$homedir/.bashrc" "$homedir/.zshrc")
for shell in "${shells[@]}"; do	
	if ! grep -Fxq "source ~/.babunrc" "$shell" ;then
		echo "Supplementing shell -> $shell"
		echo "source ~/.babunrc" >> "$shell"
	fi
done
