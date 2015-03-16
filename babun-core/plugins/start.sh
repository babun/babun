#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"
source "$babun_tools/plugins.sh"


# start plugins
plugin_install "git"
plugin_install "core"
plugin_install "cygdrive"


# Automatic start disabled for now as we have to control the order of plugin starts
#
# for startFile in $(find "$babun_plugins" -name 'start.sh');
# do
# 	bash "$startFile" || echo "Could not start $startFile"
# done
