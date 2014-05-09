#!/bin/bash
set -f 
# FIX_RELEASE
# -e 
#-o pipefail -> no pipe fail as there is not pipe in this 'cking script :)
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"
source "$babun_tools/stamps.sh"

function get_current_version {
	local current_version=$( cat "$babun/installed/babun" 2> /dev/null || echo "0.0.0" )
	echo "$current_version"
}

function get_newest_version {
	if [[ -z $CHECK_TIMEOUT_IN_SECS ]]; then 
		CHECK_TIMEOUT_IN_SECS=4
	fi
	local newest_version=$( curl --silent --connect-timeout $CHECK_TIMEOUT_IN_SECS https://raw.githubusercontent.com/babun/babun/$BABUN_BRANCH/babun.version || echo "" )
	echo "$newest_version"
}

function get_version_as_number {
	version_string=$1
	# first digit
	major=$(( ${version_string%%.*}*100000 ))
	# second digit (almost)
	minor_tmp=${version_string%.*}
	minor=$(( ${minor_tmp#*.}*1000 ))
	# third digit
	revision=$(( ${version_string##*.} ))
	version_number=$(( $major + $minor + $revision ))
	echo "$version_number"
}

function babun_check {
	# check git prompt speed
	ts=$(date +%s%N) ; 
	git --git-dir="$babun/source/.git" --work-tree="$babun/source" branch > /dev/null 2>&1 ; 
	time_taken=$((($(date +%s%N) - $ts)/1000000)) ;	
	if [[ $time_taken -gt 200 ]]; then
		# evaluate once more
		time_taken=$((($(date +%s%N) - $ts)/1000000)) ;
	fi	

	if [[ $time_taken -lt 200 ]]; then
		echo -e "Prompt speed      [OK]"
	else 
		echo -e "Prompt speed      [SLOW]"
		echo -e "Hint: your prompt is very slow. Check the installed 'BLODA' software."	
	fi	

	local newest_version=$( get_newest_version )
	if [[ -z "$newest_version" ]]; then 
		echo -e "Connection check  [FAILED]"
		echo -e "Update check      [FAILED]"
		echo -e "Hint: adjust proxy settings in ~/.babunrc and execute 'source ~/.babunrc'"
		return
	else 
		echo -e "Connection check  [OK]"
		echo -e "Update check      [OK]"
	fi

	local current_version=$( get_current_version )
        local current_version_number=$( get_version_as_number $current_version )
        local newest_version_number=$( get_version_as_number $newest_version )
        if [[ $newest_version_number -gt $current_version_number ]]; then

		echo -e "Hint: your version is outdated. Execute 'babun update'"	
	fi	
}

function guarded_babun_check {
	local check_stamp="$babun/stamps/check"	
	if ! [ $(find "$babun/stamps" -mtime 0 -type f -name 'check' 2>/dev/null || true ) ]; then
		echo "Executing daily babun check:"
		babun_check
		echo "$(date)" > "$check_stamp"
	fi
}
