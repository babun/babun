#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"


src="$babun/home/pact"

# if pact not installed
if [ ! -d "$homedir/.pact" ]; then	
	
	# installing oh-my-zsh
    /bin/cp -rf "$src/.pact" "$homedir/.pact" 
	
fi