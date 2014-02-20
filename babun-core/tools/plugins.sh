
function should_install_plugin {

	installed="/usr/local/etc/babun/installed/$plugin_name"
	if [ -f "$installed" ]; then
		typeset -i installed_version=$(cat "$installed") || installed_version=0	
		if ! [[ $plugin_version -gt $installed_version ]]; then
			echo "Skipping installation of plugin=[$plugin_name] installed_version=[$installed_version] source_version=[$plugin_version]"
			exit 0
		fi	
	fi
	echo "$plugin_version" > "$installed"
	echo "Installing plugin=[$plugin_name] installed_version=[$installed_version] source_version=[$plugin_version]"

}