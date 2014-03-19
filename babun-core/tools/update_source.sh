#!/bin/bash
set -o pipefail
set -e
set -f

# source /usr/local/etc/babun/source/babun-core/tools/procps.sh
# check_only_one_running "/tmp/update_check.sh"

babun="/usr/local/etc/babun"
source /usr/local/etc/babun/source/babun-core/tools/check.sh

if [[ -z "$BABUN_BRANCH" ]]; then
	export BABUN_BRANCH=release
fi

echo "  upstream  [$BABUN_BRANCH]"

installed_version_string=$( get_current_version )
newest_version_string=$( get_newest_version )

if [[ -z "$newest_version_string" ]]; then 
	echo "ERROR: Cannot fetch the newest version from github. Are you behind a proxy? Execute 'babun check' to find out."
	exit -1
fi

installed_version=$( get_version_as_number "$installed_version_string" )
newest_version=$( get_version_as_number "$newest_version_string" )

echo "  installed [$installed_version_string]"
echo "  newest    [$installed_version_string]"

if ! [[ $newest_version -gt $installed_version ]]; then
	echo "Skipping babun update"
	exit 0
fi

echo "Executing babun update"

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