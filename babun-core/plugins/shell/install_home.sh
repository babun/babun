#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

src="$babun/home/shell/"

# if vim not installed
if [ ! -d "$homedir/.vim" ]; then
	/bin/cp -rf "$src/.vim" "$homedir/.vim"	
	tar -xf "$src/.vim/colors.tar"
fi
