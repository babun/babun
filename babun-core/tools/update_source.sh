#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

if [[ -z "$BABUN_BRANCH" ]]; then
	export BABUN_BRANCH=release
fi

echo "Fetching the newest version of babun from [$BABUN_BRANCH]"

installed_version=$( cat "$babun/source/babun.version" )
newest_version=$( wget -q -O - https://raw.github.com/babun/babun/$BABUN_BRANCH/babun.version )

if [[ -z "$var" ]]; then 
	echo "Cannot fetch the newest version from github. Are you behind a proxy? Check settings in ~/.babunrc"
fi

if ! [[ $newest_version -gt $installed_version ]]; then
	echo "Skipping babun update -> installed_version=[$installed_version] newest_version=[$newest_version]"
	exit 0
fi

echo "Updating babun -> installed_version=[$installed_version] newest_version=[$newest_version]"


git --git-dir="$babun/source/.git" --work-tree="$babun/source" reset --hard
git --git-dir="$babun/source/.git" --work-tree="$babun/source" clean -d -x -f -f

git --git-dir="$babun/source/.git" --work-tree="$babun/source" fetch --all
git --git-dir="$babun/source/.git" --work-tree="$babun/source" pull --all

git --git-dir="$babun/source/.git" --work-tree="$babun/source" checkout $BABUN_BRANCH
git --git-dir="$babun/source/.git" --work-tree="$babun/source" clean -d -x -f -f


echo "Fixing new line feeds"
find "$babun/source/babun-core" -type f -exec dos2unix -q {} \;

echo "Making core scripts executable"
find "$babun/source/babun-core" -type f -regex '.*sh' -exec chmod 755 {} \;