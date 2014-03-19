homedir=~
eval homedir="$homedir"

function should_install_plugin {

	installed="/usr/local/etc/babun/installed/$plugin_name"
	if [ -f "$installed" ]; then
		echo "Plugin [$plugin_name]"
		echo "  installed [$installed_version]"
		echo "  newest    [$plugin_version]"
		typeset -i installed_version=$(cat "$installed") || installed_version=0	
		if ! [[ $plugin_version -gt $installed_version ]]; then
			echo "  action [skip]"
			exit 0
		fi	
	fi
	echo "$plugin_version" > "$installed"
	echo "  action [update]"

}
