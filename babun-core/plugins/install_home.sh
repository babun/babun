#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
plugins="$babun/source/babun-core/plugins"

# install home folder content
bash "$plugins/core/install_home.sh"
bash "$plugins/pact/install_home.sh"
bash "$plugins/shell/install_home.sh"
bash "$plugins/oh-my-zsh/install_home.sh"
bash "$plugins/git/install_home.sh"

