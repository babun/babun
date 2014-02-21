#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"

# plugin descriptor
plugin_name=pact
plugin_version=1
should_install_plugin


src="$babun/source/babun-core/pact/src"
dest="$babun/home/pact/.pact"

/bin/cp -rf $src/pact /usr/local/bin
chmod 755 /usr/local/bin/pact

if [ ! -d "$dest" ]; then
    mkdir "$dest"
fi

if [ ! -f "$dest/pact.repo" ]; then
    /bin/cp "$src/pact.repo" "$dest"
fi