#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun/source/babun-core/tools/script.sh"

homedir=~
eval homedir="$homedir"

function plugin_should_install {
	local plugin_name="$1"
	echo "$plugin_name"		
	local installed="/usr/local/etc/babun/installed/$plugin_name"
	if [ -f "$installed" ]; then		
		typeset -i installed_version
		local installed_version=$(cat "$installed" || echo "0") 	
		
		if ! [[ $plugin_version -gt $installed_version ]]; then
			echo "  installed [$installed_version]"
			echo "  newest    [$plugin_version]"
			echo "  action    [skip]"
			exit 0
		fi		
	fi
}

function plugin_installed_ok {
	local plugin_name="$1"
	echo "$plugin_name"		
	local installed="/usr/local/etc/babun/installed/$plugin_name"
	if [ -f "$installed" ]; then		
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
	local plugin_desc="/usr/local/etc/babun/source/$plugin_name/plugin.desc"
	if [ -f "$plugin_desc" ]; then	
		echo " Cannot find plugin descriptor [$plugin_name]"	
		exit 1
	fi	

	# loads the plugin descriptor
	source "$plugin_desc"
	
	# checks the version, installas only if the version is newer
	# uses the plugin descriptor variables
	plugin_should_install "$plugin_name"

	# execute plugin's install.sh in a separate shell
	install_script="/usr/local/etc/babun/source/$plugin_name/install.sh" 
	if [ -f "$install_script" ]; then
		bash "$install_script"	
	fi

	# sets the version to the newest one
	# uses the plugin descriptor variables
	plugin_installed_ok "$plugin_name"
}

function plugin_install_home {
	local plugin_name="$1"
	local plugin_desc="/usr/local/etc/babun/source/$plugin_name/plugin.desc"
	if [ -f "$plugin_desc" ]; then	
		echo " Cannot find plugin descriptor [$plugin_name]"	
		exit 1
	fi	

	# loads the plugin descriptor
	source "$plugin_desc"
	
	# execute plugin's install_home.sh in a separate shell
	local install_home_script="/usr/local/etc/babun/source/$plugin_name/install_home.sh" 
	if [ -f "$install_home_script" ]; then
		bash "$install_home_script"	
	fi
}


