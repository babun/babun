#!/bin/bash
set -e -f -o pipefail

babun_instance="/usr/local/etc/babun.instance"

cat /dev/null > "$babun_instance"
echo 'babun=/usr/local/etc/babun' >> "$babun_instance"
echo 'babun_source="$babun/source"' >> "$babun_instance"
echo 'babun_plugins="$babun/source/babun-core/plugins"' >> "$babun_instance"
echo 'babun_tools="$babun/source/babun-core/tools"' >> "$babun_instance"