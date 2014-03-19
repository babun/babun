homedir=~
eval homedir="$homedir"

function should_install_plugin {
	echo "$plugin_name"		
	installed="/usr/local/etc/babun/installed/$plugin_name"
	if [ -f "$installed" ]; then		
		typeset -i installed_version=$(cat "$installed") || installed_version=0	

		if ! [[ $plugin_version -gt $installed_version ]]; then
			echo "  installed '$installed_version'"
			echo "  newest    '$plugin_version'"
			echo "  action    'skip'"
			exit 0
		fi		
	fi

	echo "$plugin_version" > "$installed"

	echo "  installed '$installed_version'"
	echo "  newest    '$plugin_version'"
	echo "  action    'update'"
}
