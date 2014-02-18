#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
src="$babun/babun-core/src"
dest="~/.pact"

\cp -rf $src/pact /usr/local/bin
chmod 755 /usr/local/bin/pact

if [ ! -d "$dest" ]; then
    mkdir "$dest"
fi

if [ ! -f "$dest/pact.repo" ]; then
    cp "$src/pact.repo" "$dest"
fi