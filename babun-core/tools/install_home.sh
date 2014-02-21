#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

# install home folder content
bash "$babun/source/babun-core/core/install_home.sh"
bash "$babun/source/babun-core/pact/install_home.sh"
bash "$babun/source/babun-core/oh-my-zsh/install_home.sh"

