#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/home.skip"

homedir=~
eval homedir=$homedir

src="$babun/home/"
dest="$homedir"

if [ ! -d "$dest/.oh-my-zsh" ]; then
    /bin/cp -rf "$src/.oh-my-zsh" "$dest/.oh-my-zsh" 
fi

for src_file in $(find "$src" -name ".oh-my-zsh" -prune -o -type f -print ); 
do
	src_filename="$( basename "$src_file" )"
	src_relfile="${src_file#$src}"	
	src_relpath="${src_relfile#$src_filename}"
	
	target_path="$dest/$src_relpath"
	target_file="$target_path/$src_filename"
		
	echo $src_relfile
	if [ "${skip["$src_relfile"]}" == "true" ]; then
		echo "Skipping $src_relfile" 
	else 
		echo "Installing $src_relfile" 
		if [ -f "$target_file" ]; then
			if ! cmp -s "$src_file" "$target_file"; then
	    		echo "Backing up $target_file" 
				mv -f "$target_file" "$target_file.babun-backup"	 
			fi		
		fi    
		mkdir -p "$target_path" 		
		/bin/cp -rf "$src_file" "$target_file"	
	fi
done

# fixing oh-my-zsh
zsh -c "source ~/.zshrc; rm -f \"$homedir/.zcompdump\"; compinit -u"
zsh -c "source ~/.zshrc; cat \"$homedir/.zcompdump\" > \"$homedir/.zcompdump-\"*"