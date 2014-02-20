#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

echo "Fetching the newest version of babun"
git -C "$babun/source" fetch --all
git -C "$babun/source" reset --hard origin/master