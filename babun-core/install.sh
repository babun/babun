#!/bin/bash
set -o pipefail
set -e
set -f

#INSTALL PACT
chmod 755 "$home/pact/install.sh"
bash "$home/pact/install.sh"

#INSTALL SHELL
chmod 755 "$home/shell/install.sh"
bash "$home/shell/install.sh"

