homedir=~
eval homedir="$homedir"

function should_install_plugin {

	installed="/usr/local/etc/babun/installed/$plugin_name"
	if [ -f "$installed" ]; then
		echo "$plugin_name"		
		typeset -i installed_version=$(cat "$installed") || installed_version=0	

		echo "  installed '$installed_version'"
		echo "  newest    '$plugin_version'"

		if ! [[ $plugin_version -gt $installed_version ]]; then
			echo "  action   'skip'"
			exit 0
		fi	
	fi
	echo "$plugin_version" > "$installed"
	echo "  action    'update'"

}
