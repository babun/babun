#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

if [[ -z "$BABUN_BRANCH" ]]; then
	export BABUN_BRANCH=master
fi

echo "Fetching the newest version of babun from [$BABUN_BRANCH]"

# for remote in `git --git-dir="$babun/source/.git" branch -r`; do
    # git branch --track $remote
# done

git --git-dir="$babun/source/.git" fetch --all
git --git-dir="$babun/source/.git" pull --all
git --git-dir="$babun/source/.git" reset --hard
git --git-dir="$babun/source/.git" checkout $BABUN_BRANCH
git --git-dir="$babun/source/.git" clean -d -x -f -f


echo "Changing new line feeds"
find "$babun/source/babun-core" -type f -exec dos2unix -q {} \;

echo "Making scripts executable"
find "$babun/source/babun-core" -type f -regex '.*sh' -exec chmod 755 {} \;