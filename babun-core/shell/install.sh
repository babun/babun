#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
src="$babun/source/babun-core/shell/src/"
dest="$babun/home/"

/bin/cp -rf "$src/." "$dest" 