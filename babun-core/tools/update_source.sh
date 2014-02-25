#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

if [[ -z "$BABUN_BRANCH" ]]; then
	export BABUN_BRANCH=master
fi

echo "Fetching the newest version of babun from [$BABUN_BRANCH]"


installed=$( cat "$babun/source/babun.version" )
github=$( curl https://raw.github.com/babun/babun/$BABUN_BRANCH/babun.version )

echo "$installed vs $github"


git --git-dir="$babun/source/.git" --work-tree="$babun/source" fetch --all
git --git-dir="$babun/source/.git" --work-tree="$babun/source" pull --all
git --git-dir="$babun/source/.git" --work-tree="$babun/source" reset --hard
git --git-dir="$babun/source/.git" --work-tree="$babun/source" checkout $BABUN_BRANCH
git --git-dir="$babun/source/.git" --work-tree="$babun/source" clean -d -x -f -f


echo "Fixing new line feeds"
find "$babun/source/babun-core" -type f -exec dos2unix -q {} \;

echo "Making core scripts executable"
find "$babun/source/babun-core" -type f -regex '.*sh' -exec chmod 755 {} \;