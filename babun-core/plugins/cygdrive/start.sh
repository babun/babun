#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

for root_dir in $(find / -maxdepth 1 -type l)
do		
	link_target=$(readlink $root_dir)

	if [[ "$link_target" =~ ^\/cygdrive\/.$ ]]; then
		rm "$root_dir" || true
	fi
done

if ! [[ "$DISABLE_PLUGIN_CYGDRIVE" == "true" ]]; then

	for cygdrive_dir in $(find /cygdrive/ -maxdepth 1 -type d 2>/dev/null)
	do
		drive_name=$(basename $cygdrive_dir)

		if [[ "$drive_name" != "cygdrive" && ! -e "/$drive_name" ]]; then
			ln -s "$cygdrive_dir" "/$drive_name"
		fi
	done
	
fi
