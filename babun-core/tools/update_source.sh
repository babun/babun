#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

echo "Fetching the newest version of babun"
git -C "$babun/source" fetch --all
git -C "$babun/source" reset --hard origin/master

echo "Changing new line feeds"
find "$babun/source/babun-core" -type f -exec dos2unix {} \;

echo "Making scripts executable"
find "$babun/source/babun-core" -type f -regex '.*sh' -exec chmod 755 {} \;