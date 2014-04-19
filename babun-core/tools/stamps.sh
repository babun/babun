#!/bin/bash
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"
stamps="$babun/stamps"

if ! [ -d "$stamps" ]; then 
	mkdir -p "$stamps"
fi
