#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

if [[ -z "$BABUN_BRANCH" ]]; then
	export BABUN_BRANCH=release
fi

echo "Fetching the newest version of babun from [$BABUN_BRANCH]"

installed_version=$( cat "$babun/installed/babun" 2> /dev/null || echo "0" )
newest_version=$( curl --silent --connect-timeout 8 https://raw.github.com/babun/babun/$BABUN_BRANCH/babun.version || echo "" )


if [[ -z "$newest_version" ]]; then 
	echo "ERROR: Cannot fetch the newest version from github. Are you behind a proxy? Check settings in ~/.babunrc"
	exit -1
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

core=
# install/update plugins
"$babun"/source/babun-core/tools/install.sh || { echo "ERROR: Could not update babun!"; exit -2; }
 
# install/update home folder
"$babun"/source/babun-core/tools/install_home.sh || { echo "ERROR: Could not update home folder!"; exit -3; }

# set the newest version marker
cat "$babun/source/babun.version" > "$babun/installed/babun"