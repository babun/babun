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


src="$babun/source/babun-core/plugins/shell/src/"
dest="$babun/home/shell/"


/bin/cp -rf $src/minttyrc /etc/minttyrc
/bin/cp -rf $src/nanorc /etc/nanorc
/bin/cp -rf $src/vimrc /etc/vimrc


mkdir -p "$dest"
/bin/cp -rf "$src/.vim" "$dest/.vim" 

