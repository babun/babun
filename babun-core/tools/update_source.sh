#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"
source "$babun_tools/check.sh"
source "$babun_tools/git.sh"

option="$1"

function check_cygwin_version() {

	local newest_cygwin_version=$( get_newest_cygwin_version )
	if [[ -z "$newest_cygwin_version" ]]; then 
		echo "ERROR: Cannot fetch the newest Cygwin version from github. Are you behind a proxy? Execute 'babun check' to find out."
		exit -1
	else
		
		local newest_cygwin_version_number=$( get_version_as_number $newest_cygwin_version )
		local current_cygwin_version=$( get_current_cygwin_version )
		local current_cygwin_version_number=$( get_version_as_number $current_cygwin_version )
		echo -e "Checking Cygwin version:"
		echo "  installed [$current_cygwin_version]"
		echo "  newest    [$newest_cygwin_version]"
		if [[ $newest_cygwin_version_number -gt $current_cygwin_version_number ]]; then
			local babun_root=$( cygpath -ma "/" | sed "s#/cygwin##g" ) 
			echo 
			echo -e "It's necessary to update Cygwin! Unfortunately it's not possible to do it from within babun."
			echo -e "Execute the following steps to update the underlying Cygwin instance:"
			echo -e "  - close all babun windows"
			echo -e "  - open the following folder $babun_root"
			echo -e "  - execute the update.bat script"
		else 
			echo -e "Cygwin is up to date"
		fi 		
	fi

}

if [[ -z "$BABUN_BRANCH" ]]; then
	export BABUN_BRANCH=release
fi
echo "  upstream  [$BABUN_BRANCH]"


installed_version_string=$( get_current_version )
if [[ "$option" != "--force" ]]; then	
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
		check_cygwin_version
		exit 0
	fi
else 
	echo "  installed [$installed_version_string]"
	echo "  newest    [FORCE]"
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