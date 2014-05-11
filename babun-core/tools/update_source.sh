#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"
source "$babun_tools/check.sh"

local option="$1"

if [[ -z "$BABUN_BRANCH" ]]; then
	export BABUN_BRANCH=release
fi
echo "  upstream  [$BABUN_BRANCH]"

if [[ "$option" != "--force" ]]; then
	installed_version_string=$( get_current_version )
	newest_version_string=$( get_newest_version )

	if [[ -z "$newest_version_string" ]]; then 
		echo "ERROR: Cannot fetch the newest version from github. Are you behind a proxy? Execute 'babun check' to find out."
		exit -1
	fi

	installed_version=$( get_version_as_number "$installed_version_string" )
	newest_version=$( get_version_as_number "$newest_version_string" )

	echo "  installed [$installed_version_string]"
	echo "  newest    [$newest_version_string]"

	if ! [[ $newest_version -gt $installed_version ]]; then
		echo "Babun is up to date"
		exit 0
	fi
fi

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


"$babun"/source/babun-core/tools/update_exec.sh
