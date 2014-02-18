#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
src="$babun/babun-core/pact/src"

homedir=~
eval homedir=$homedir
dest="$homedir/.pact"

/bin/cp -rf $src/pact /usr/local/bin
chmod 755 /usr/local/bin/pact

if [ ! -d "$dest" ]; then
    mkdir "$dest"
fi

if [ ! -f "$dest/pact.repo" ]; then
    /bin/cp "$src/pact.repo" "$dest"
fi