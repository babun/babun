#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"

declare -A skip
skip[".babunrc"]=true
skip[".zshrc"]=true

src="$babun/home/shell/"
dest="$homedir"

for src_file in $(find "$src" -type f ); 
do
	src_filename="$( basename "$src_file" )"
	src_relfile="${src_file#$src}"	
	src_relpath="${src_relfile%$src_filename}"
	
	target_path="$dest/$src_relpath"
	target_file="$target_path/$src_filename"

	#echo "---------------"
	#echo $src_file
	#echo "$src_filename === $src_relfile === $src_relpath"
	#echo "$target_path -> $target_file"	
	#echo "---------------"
		
	if [ -f "$target_file" ] && [ "${skip["$src_relfile"]}" == "true" ]; then
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

