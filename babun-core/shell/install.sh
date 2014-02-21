#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"

# plugin descriptor
plugin_name=shell
plugin_version=1
should_install_plugin


src="$babun/source/babun-core/shell/src/"
dest="$babun/home/shell/"

mkdir -p "$dest"
/bin/cp -rf "$src/." "$dest" 
