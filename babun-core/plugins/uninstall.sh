#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"

source "$babun_tools/script.sh"
source "$babun_tools/plugins.sh"

# uninstall plugins
plugin_uninstall "shell-here"