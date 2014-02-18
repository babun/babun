#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

#INSTALL PACT
chmod 755 "$babun/babun-core/pact/install.sh"
bash "$babun/babun-core/pact/install.sh"

#INSTALL SHELL
chmod 755 "$babun/babun-core/shell/install.sh"
bash "$babun/babun-core/shell/install.sh"

