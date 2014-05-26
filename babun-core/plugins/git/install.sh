#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

typeset -i installed_version
local installed_version=$(echo "$1" || echo "0") 

# COMPATIBILITY FIXES
# INSTALLED_VERSION=1
if [[ "$installed_version" -le 1 ]]; then
	echo "Installing missing gettext and libsasl2"
	pact install gettext || echo "Failed to install gettext"
	pact install libsasl2 || echo "Failed to install libsasl2"
fi
