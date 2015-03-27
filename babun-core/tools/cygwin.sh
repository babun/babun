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
			local babun_root=$( cygpath -ma "/" | sed "s#/cygwin##g" ) 
			local running_count = $( ps | grep /usr/bin/mintty | wc -l )
			if [[ $running_count -gt 1 ]]; then
				echo -e "ERROR: There's $running_count running babun instance[s]. Close all OTHER babun windows [mintty processes] and try again."
				return
			fi
			echo "cygstart"
			# cygstart $babun_root/update.bat && pkill 'mintty'
		fi 		
	fi

}