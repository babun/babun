babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/stamps.sh"

function get_current_version {
	local current_version=$( cat "$babun/installed/babun" 2> /dev/null || echo "0" )
	echo "$current_version"
}

function get_newest_version {
	local newest_version=$( curl --silent --connect-timeout 8 https://raw.github.com/babun/babun/$BABUN_BRANCH/babun.version || echo "" )
	echo "$newest_version"
}

function babun_check {

	local newest_version=$(get_newest_version)
	if [[ -z "$newest_version" ]]; then 
		echo -e "Connection check  [FAILED]"
		echo -e "Update check      [FAILED]"
		echo -e "Hint: adjust proxy settings in ~/.babunrc and execute 'source ~/.babunrc'"
		return
	else 
		echo -e "Connection check  [OK]"
		echo -e "Update check      [OK]"
	fi

	local current_version=$(get_current_version)
	if [[ $newest_version -gt $current_version ]]; then
		echo -e "Hint: your version is outdated. Execute 'babun update'"	
	fi
	
}

function guarded_babun_check {
	local babun="/usr/local/etc/babun"
	local check_stamp="$babun/stamps/check"

	if ! [ $(find "$babun/stamps" -mtime 0 -type f -name 'check' 2>/dev/null) ]; then
		babun_check
		echo "$(date)" > "$check_stamp"
	fi
}