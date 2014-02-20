#!/bin/bash
set -o pipefail
set -e
set -f

# plugin descriptor
name=pact
version=1


babun="/usr/local/etc/babun"
src="$babun/source/babun-core/pact/src"
dest="$babun/home/.pact"

/bin/cp -rf $src/pact /usr/local/bin
chmod 755 /usr/local/bin/pact

if [ ! -d "$dest" ]; then
    mkdir "$dest"
fi

if [ ! -f "$dest/pact.repo" ]; then
    /bin/cp "$src/pact.repo" "$dest"
fi