#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/tools/stamps.sh"

update_stamp="$babun/stamps/update"

if [ ! -f "$update_stamp" ]; then 
	echo "update" > "$update_stamp"
fi

if ! [ $(find "$babun/stamps" -mtime 0 -type f -name 'update' 2>/dev/null) ]

	if [[ -z "$BABUN_BRANCH" ]]; then
		export BABUN_BRANCH=release
	fi

	babun_version=$( curl --silent --connect-timeout 8 https://raw.github.com/babun/babun/$BABUN_BRANCH/babun.version || echo "" )
	
	#if [[ -z "$babun_version" ]]; then 
	#	echo -e "Update check\t[NEWER VERSION FOUND] -> Execute 'babun update'"
	#else 
	#	echo -e "Update check\t[OK]"
	#fi
	#echo "proxy" > "$proxy_stamp"

fi