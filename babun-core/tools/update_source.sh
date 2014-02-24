#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

if [[ -z "$BABUN_BRANCH" ]]; then
	export BABUN_BRANCH=master
fi

echo "Fetching the newest version of babun"
git --git-dir="$babun/source/.git" fetch --all
git --git-dir="$babun/source/.git" reset --hard origin/master
git --git-dir="$babun/source/.git" checkout $BABUN_BRANCH

echo "Changing new line feeds"
find "$babun/source/babun-core" -type f -exec dos2unix {} \;

echo "Making scripts executable"
find "$babun/source/babun-core" -type f -regex '.*sh' -exec chmod 755 {} \;