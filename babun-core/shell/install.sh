#!/bin/bash
set -o pipefail
set -e
set -f

src="~/.babun/babun-core/src/"
dest="~/"

for path in $(find "$src" -type f); 
do
	file="${path#$src}"
	target="$dest/$file"
	if [ -f "$target" ]; then
		echo "Backing up $target" 
		mv -f "$target" "$target.backup"	 
	fi    
done
/cp -rf "$src" "$dest" 