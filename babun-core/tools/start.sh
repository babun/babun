#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

for startFile in $(find "$babun_plugins" -name 'start.sh');
do
	bash "$startFile" || echo "Could not start $startFile"
done
