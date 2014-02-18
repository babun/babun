#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
src="$babun/babun-core/shell/src/"

homedir=~
eval homedir=$homedir
dest="$homedir/"

for src_file in $(find "$src" -type f); 
do
	src_filename="${src_file#$src}"
	target_file="$dest/$src_filename"
	echo "[$src_file] [$src_filename] [$target_filename]" 
	
	if [ -f "$target_file" ]; then
		if [ ! cmp -s "$src_file" "$target_file"] ; then
    		echo "Backing up $target_file" 
			mv -f "$target_file" "$target_file.backup"	 
		fi		
	fi    
done
/bin/cp -rf "$src/." "$dest" 