#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/version.sh"

# plugin descriptor
plugin_name=babun
plugin_version=1
should_install_plugin


src="$babun/source/babun-core/babun/src"

/bin/cp -rf $src/babun /usr/local/bin
chmod 755 /usr/local/bin/babun

/bin/cp -rf $src/babun.rc /usr/local/etc
/bin/cp -rf $src/babun.bash /usr/local/etc
/bin/cp -rf $src/babun.zsh /usr/local/etc

