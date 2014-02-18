#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

echo "Executing pact/install.sh"
bash "$babun/babun-core/pact/install.sh"

echo "Executing shell/install.sh"
bash "$babun/babun-core/shell/install.sh"

