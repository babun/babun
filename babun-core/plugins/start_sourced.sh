#!/bin/bash

# Source the passed plugin's "start_sourced.sh" script in the current shell
# process. By definition, this is less safe than running that plugin's
# "start.sh" script in a new bash process and hence should be used only where
# needed (e.g., to modify the current shell's ${PATH}).
#
# This function is defined here rather than in "tools/plugins.sh", the customary
# script for plugin-specific utility functions, to avoid polluting the current
# shell with extraneous functions.
function _plugin_start_sourced {
	local plugin_name="$1"
	local start_sourced_script="$babun_plugins/$plugin_name/start_sourced.sh"

	if [[ -f "$start_sourced_script" ]]; then
        source "$start_sourced_script" ||
            echo "Could not start sourced plugin [$plugin_name]" 1>&2
    else
		echo "ERROR: Cannot find plugin start_sourced.sh script [$plugin_name] [$start_sourced_script]" 1>&2
	fi 
}

# Start all plugins modifying the current shell process.
_plugin_start_sourced "conda"

# Undefine our utility function.
unset -f _plugin_start_sourced
