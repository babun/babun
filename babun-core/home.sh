#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

homedir=~
eval homedir=$homedir

/bin/cp -rf "$babun/home/." "$homedir"