#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

function plugin_should_install {
	local plugin_name="$1"	
	local __result=$2
	local installed="$babun/installed/$plugin_name"
	if [[ -f "$installed" ]]; then		
		typeset -i installed_version
		local installed_version=$(cat "$installed" || echo "0") 	
		
		if ! [[ $plugin_version -gt $installed_version ]]; then
			echo "  installed [$installed_version]"
			echo "  newest    [$plugin_version]"
			echo "  action    [skip]"
			eval $__result="0"
			return 0
		fi		
	fi
	eval $__result="1"
}

function plugin_installed_ok {
	local plugin_name="$1"	
	local installed="$babun/installed/$plugin_name"
	if [[ -f "$installed" ]]; then		
		typeset -i installed_version
		local installed_version=$(cat "$installed" || echo "0") 	
	fi

	if [[ -z "$installed_version" ]]; then
		local installed_version="none"
	fi

	echo "$plugin_version" > "$installed"
	echo "  installed [$installed_version]"
	echo "  newest    [$plugin_version]"
	echo "  action    [execute]"
}

function plugin_install {	
	local plugin_name="$1"	
	echo "Installing plugin [$plugin_name]"
	local plugin_desc="$babun/source/babun-core/plugins/$plugin_name/plugin.desc"
	if [[ ! -f "$plugin_desc" ]]; then	
		echo "ERROR: Cannot find plugin descriptor [$plugin_name] [$plugin_desc]"	
		exit 1
	fi	

	# loads the plugin descriptor
	source "$plugin_desc"
	
	# checks the version, installas only if the version is newer
	# uses the plugin descriptor variables
	plugin_should_install "$plugin_name" result
	if [[ "$result" -eq "0" ]]; then
		return 0
	fi
		
	# execute plugin's install.sh in a separate shell
	install_script="$babun/source/babun-core/plugins/$plugin_name/install.sh" 
	if [[ -f "$install_script" ]]; then
		bash "$install_script"
	fi

	# sets the version to the newest one
	# uses the plugin descriptor variables
	plugin_installed_ok "$plugin_name"
}

function plugin_install_home {
	local plugin_name="$1"
	local installed_version=$(cat "$babun/installed/$plugin_name" || echo "0") 
	echo "Installing plugin's home [$plugin_name]"
	local plugin_desc="$babun/source/babun-core/plugins/$plugin_name/plugin.desc"
	if [[ ! -f "$plugin_desc" ]]; then	
		echo "ERROR: Cannot find plugin descriptor [$plugin_name] [$plugin_desc]"	
		exit 1
	fi	

	# loads the plugin descriptor
	source "$plugin_desc"
	
	# execute plugin's install_home.sh in a separate shell
	local install_home_script="$babun/source/babun-core/plugins/$plugin_name/install_home.sh" 
	
	if [[ ! -f "$install_home_script" ]]; then
		echo "ERROR: Cannot find plugin install_home.sh script [$plugin_name] [$install_home_script]"	
		exit 1	
	fi
	bash "$install_home_script"	"$installed_version"
}

function plugin_start {
	local plugin_name="$1"

	local start_script="$babun_plugins/$plugin_name/start.sh"
	if [[ ! -f "$install_home_script" ]]; then
		echo "ERROR: Cannot find plugin start.sh script [$plugin_name] [$start_script]"	
		exit 1	
	fi 

	bash "$start_script" || echo "Could not start plugin [$plugin_name]"
}