#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

src="$babun_source/babun-dist"
babun_root=/cygdrive/$( cygpath -ma "/" | sed "s/://"g )/..

typeset -i installed_version
installed_version=$(echo "$1" || echo "0") 

# set the cygwin's installed version
if ! [[ -f "$babun/installed/cygwin" ]]; then
	echo -e "1.7.29" > "$babun/installed/cygwin"
fi

# copy dist files to the dist folder
cp -rf "$src/fonts" "$babun_root"
cp -rf "$src/tools" "$babun_root"

# copy start/update scripts
# not overriding start.bat for now -> but possible
# cp -rf "$src/start/start.bat" "$babun_root"
cp -rf "$src/start/update.bat" "$babun_root"
cp -rf "$src/start/rebase.bat" "$babun_root"
