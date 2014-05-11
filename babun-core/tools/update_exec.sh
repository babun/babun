#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

# install/update plugins
"$babun"/source/babun-core/plugins/install.sh || { echo "ERROR: Could not update babun!"; exit -2; }
 
# install/update home folder
"$babun"/source/babun-core/plugins/install_home.sh || { echo "ERROR: Could not update home folder! Try executing 'babun install' manually!"; exit -3; }

# set the newest version marker
cat "$babun/source/babun.version" > "$babun/installed/babun"