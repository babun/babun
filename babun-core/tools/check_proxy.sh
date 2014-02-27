#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/tools/stamps.sh"

proxy_stamp="$babun/stamps/proxy"

if [ ! -f "$proxy_stamp" ]; then 
	echo "proxy" > "$proxy_stamp"
fi

if ! [ $(find "$babun/stamps" -mtime 0 -type f -name 'proxy' 2>/dev/null) ]

	babun_version=$( curl --silent --connect-timeout 8 https://raw.github.com/babun/babun/master/babun.version || echo "" )
	if [[ -z "$babun_version" ]]; then 
		echo -e "Internet connection\t[FAILED] -> Adjust proxy settings in ~/.babunrc and execute 'source ~/.babunrc'"
	else 
		echo -e "Internet connection\t[OK]"
	fi
	echo "proxy" > "$proxy_stamp"

fi