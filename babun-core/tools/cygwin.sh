#!/bin/bash
set -e -f -o pipefail
source "$babun_tools/check.sh"

function update_cygwin_instance() {

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
			echo "Cygwin is outdated"
			local babun_root=$( cygpath -ma "/" | sed "s#/cygwin##g" ) 
			local running_count=$( ps | grep /usr/bin/mintty | wc -l )
			if [[ $running_count -gt 1 ]]; then
				echo -e "------------------------------------------------------------------"
				echo -e "ERROR: Cannot upgrade Cygwin! There's $running_count running babun instance[s]."
				echo -e "Close all OTHER babun windows [mintty] and execute 'babun update'"
				echo -e "------------------------------------------------------------------"
				return
			fi
			echo -e "------------------------------------------------------------------"
			echo -e "Babun will close itself in 5 seconds to upgrade the underlying Cygwin instance."
			echo -e "DO NOT close the window during the update process!"
			echo -e "------------------------------------------------------------------"
			sleep 5
			echo -e "Upgrading Cygwin in:"
			for i in {3..1}
			do
			   echo "$i"
			   sleep 1
			done
			echo "0"
			cygstart "$babun_root/update.bat" && pkill 'mintty'
		else
			echo "Cygwin is up to date" 
		fi		
	fi

}