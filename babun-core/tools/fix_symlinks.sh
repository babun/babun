#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun/source/babun-core/tools/script.sh"

if ! [ -f "/etc/postinstall/symlinks_repair.sh.done" ]; then
	echo "Fixing symlinks for the installation"
	dos2unix "/etc/postinstall/symlinks_repair.sh"
	chmod 755 "/etc/postinstall/symlinks_repair.sh"
	bash "/etc/postinstall/symlinks_repair.sh"
fi
