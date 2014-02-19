#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
src="$babun/source/babun-core/babun/src"

/bin/cp -rf $src/babun /usr/local/bin
chmod 755 /usr/local/bin/babun
