#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/home.skip"

homedir=~
eval homedir=$homedir

src="$babun/home"
dest="$homedir"

for src_file in $(find "$src" -type f); 
do
	src_filename="${src_file#$src}"
	target_file="$dest/$src_filename"
		
	if [ ! skip["$src_filename"] ]; then
		echo "Installing $src_filename" 
		if [ -f "$target_file" ]; then
			if [ ! cmp -s "$src_file" "$target_file" ]; then
	    		echo "Backing up $target_file" 
				mv -f "$target_file" "$target_file.backup"	 
			fi		
		fi    		
		/bin/cp -rf "$src_file" "$target_file"
	else 
		echo "Skipping $src_filename" 
	fi
done




# fixing oh-my-zsh
zsh -c "source ~/.zshrc; rm -f \"$homedir/.zcompdump\"; compinit -u"
zsh -c "source ~/.zshrc; cat \"$homedir/.zcompdump\" > \"$homedir/.zcompdump-\"*"