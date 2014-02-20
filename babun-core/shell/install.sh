#!/bin/bash
set -o pipefail
set -e
set -f

# plugin descriptor
plugin_name=shell
plugin_version=1
should_install_plugin


babun="/usr/local/etc/babun"
src="$babun/source/babun-core/shell/src/"
dest="$babun/home/"

/bin/cp -rf "$src/." "$dest" 