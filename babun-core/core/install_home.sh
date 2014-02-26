#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"

src="$babun/home/core"
dest="$homedir"

if [ ! -f "$dest/.babunrc" ]; then
	/bin/cp -rf "$src/.babunrc" "$dest/.babunrc"
	branch=$( git --git-dir="$babun/source/.git" --work-tree="$babun/source" rev-parse --abbrev-ref HEAD )
	if ! [[ "release" == "$branch*" ]]; then
		echo "" >> "$dest/.babunrc"
		echo "export BABUN_BRANCH=$branch" >> "$dest/.babunrc"
	fi
fi

