#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
bash "$babun/babun-core/pact/install.sh"
bash "$babun/babun-core/shell/install.sh"

