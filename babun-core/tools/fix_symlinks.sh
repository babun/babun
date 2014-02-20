#!/bin/bash
set -o pipefail
set -e
set -f

if ! [ -f "/etc/postinstall/symlinks_repair.sh.done" ]; then
	echo "Fixing symlinks for the installation"
	dos2unix "/etc/postinstall/symlinks_repair.sh"
	chmod 755 "/etc/postinstall/symlinks_repair.sh"
	bash "/etc/postinstall/symlinks_repair.sh"
fi
