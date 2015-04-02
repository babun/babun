#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"
source "$babun_tools/procps.sh"
source "$babun_tools/cygwin.sh"

permcheck=$( chmod 755 /usr/ 2> /dev/null || echo "FAILED" )
if [[  $permcheck == "FAILED" ]]; then
  echo "You don't have write permission to / filesystem. Aborting!"
  echo "Hint: Have you installed babun as admin and run it from a non-admin account? Retry as admin." 
  exit -1       
fi  

# install/update plugins
"$babun"/source/babun-core/plugins/install.sh || { echo "ERROR: Could not update babun!"; exit -2; }
 
# install/update home folder
"$babun"/source/babun-core/plugins/install_home.sh || { echo "ERROR: Could not update home folder! Try executing 'babun install' manually!"; exit -3; }

# set the newest version marker
cat "$babun/source/babun.version" > "$babun/installed/babun"

# execute cygwin update
update_cygwin_instance

# login to the default shell once again to execute plugin startup sequence
proc_shell_login
