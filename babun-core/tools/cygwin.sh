#!/bin/bash
set -e -f -o pipefail

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