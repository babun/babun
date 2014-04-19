#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

src="$babun_source/babun-core/plugins/shell/src/"
dest="$babun/home/shell/"

/bin/cp -rf $src/minttyrc /etc/minttyrc
/bin/cp -rf $src/nanorc /etc/nanorc
/bin/cp -rf $src/vimrc /etc/vimrc

mkdir -p "$dest"
/bin/cp -rf "$src/.vim" "$dest/.vim" 
