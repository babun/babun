#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

local src="$babun_source/babun-dist"
local babun_root=/cygdrive/$( cygpath -ma "/" | sed "s/://"g )/..

typeset -i installed_version
installed_version=$(echo "$1" || echo "0") 

# set the babun's installed version
cat "$babun_source/babun.version" > "$babun/installed/babun"

# set the cygwin's installed version
if ! [[ -f "$babun/installed/cygwin" ]]; then
	echo -e "1.7.29" > "$babun/installed/cygwin"
fi

# copy dist files to the dist folder
cp -rf "$src/fonts" "$dest"
cp -rf "$src/tools" "$dest"

# copy start/update scripts
# not overriding start.bat for now -> but possible
# cp -rf "$src/start/start.bat" "$dest"
cp -rf "$src/start/update.bat" "$dest"
cp -rf "$src/start/rebase.bat" "$dest"
