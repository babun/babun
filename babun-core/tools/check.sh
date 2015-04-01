#!/bin/bash

# FIX_RELEASE 
# set (the following commands do not work at all)
# -f (does not work with oh-my-zsh)
# -e (does not work )
# -o pipefail (no pipe fail as there is not pipe in this 'cking script :))
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"
source "$babun_tools/stamps.sh"

function get_current_version {
	dos2unix $babun/installed/babun 2> /dev/null
	local current_version=$( cat "$babun/installed/babun" 2> /dev/null || echo "0.0.0" )
	echo "$current_version"
}

function get_newest_version {
	if [[ -z $CHECK_TIMEOUT_IN_SECS ]]; then 
		CHECK_TIMEOUT_IN_SECS=4
	fi
	local newest_version=$( curl --silent --insecure --user-agent "$USER_AGENT" --connect-timeout $CHECK_TIMEOUT_IN_SECS --location https://raw.githubusercontent.com/babun/babun/$BABUN_BRANCH/babun.version || echo "" )
	echo "$newest_version"
}

function get_current_cygwin_version {
	if [[ ! -f "$babun/installed/cygwin" ]]; then
		echo "1.7.29" > "$babun/installed/cygwin" 
	fi
	dos2unix $babun/installed/cygwin 2> /dev/null
	local current_cygwin_version=$( cat "$babun/installed/cygwin" 2> /dev/null || echo "0.0.0" )
	echo "$current_cygwin_version"
}

function get_newest_cygwin_version {
	if [[ -z $CHECK_TIMEOUT_IN_SECS ]]; then 
		CHECK_TIMEOUT_IN_SECS=4
	fi
	local newest_cygwin_version=$( curl --silent --insecure --user-agent "$USER_AGENT" --connect-timeout $CHECK_TIMEOUT_IN_SECS --location https://raw.githubusercontent.com/babun/babun-cygwin/master/cygwin.version || echo "" )
	echo "$newest_cygwin_version"
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

function exec_check_prompt {
	# check git prompt speed
	ts=$(date +%s%N) ; 
	git --git-dir="$babun/source/.git" --work-tree="$babun/source" branch > /dev/null 2>&1 ; 
	time_taken=$((($(date +%s%N) - $ts)/1000000)) ;	
	if [[ $time_taken -gt 200 ]]; then
		# evaluate once more
		time_taken=$((($(date +%s%N) - $ts)/1000000)) ;
	fi	

	if [[ $time_taken -lt 500 ]]; then
		echo -e "Prompt speed      [OK]"
	else 
		echo -e "Prompt speed      [SLOW]"
		echo -e "Hint: your prompt is very slow. Check the installed 'BLODA' software."	
	fi	
}

function exec_check_permissions {
	permcheck=$( chmod 755 /usr/ 2> /dev/null || echo "FAILED" )
	if [[  $permcheck == "FAILED" ]]; then
		echo -e "File permissions  [FAILED]"
		echo -e "Hint: Have you installed babun as admin and run it from a non-admin account?"			
	else 
		echo -e "File permissions  [OK]"
	fi	
}

function exec_check_cygwin {
	local newest_cygwin_version=$( get_newest_cygwin_version )
	if [[ -z "$newest_cygwin_version" ]]; then 
		echo -e "Cygwin check      [FAILED]"
		return
	else
		
		local newest_cygwin_version_number=$( get_version_as_number $newest_cygwin_version )
		local current_cygwin_version=$( get_current_cygwin_version )
		local current_cygwin_version_number=$( get_version_as_number $current_cygwin_version )
		if [[ $newest_cygwin_version_number -gt $current_cygwin_version_number ]]; then
			echo -e "Cygwin check      [OUTDATED]"
			echo -e "Hint: the underlying Cygwin kernel is outdated. Execute 'babun update' and follow the instructions!"	
		else 
			echo -e "Cygwin check      [OK]"
		fi 		
	fi
}

function babun_check {	
	exec_check_prompt
	exec_check_permissions

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

	exec_check_cygwin	
}


function guarded_babun_check {
	local check_stamp="$babun/stamps/check"	
	if ! [ $(find "$babun/stamps" -mtime 0 -type f -name 'check' 2>/dev/null || true ) ]; then
		echo "Executing daily babun check:"
		babun_check
		echo "$(date)" > "$check_stamp"
	fi
}
