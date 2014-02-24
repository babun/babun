#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"

src="$babun/home/core"
dest="$homedir"

if [ ! -f "$dest/.babunrc" ]; then
	/bin/cp -rf "$src/.babunrc" "$dest/.babunrc"
fi
