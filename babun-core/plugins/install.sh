#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
plugins="$babun/source/babun-core/plugins"

# prepare the environment
mkdir -p "$babun/home"
mkdir -p "$babun/external"
mkdir -p "$babun/installed"

# fix the symlinks if necessary
bash "$babun/source/babun-core/tools/fix_symlinks.sh"

# install plugins
bash "$plugins/core/install.sh"
bash "$plugins/pact/install.sh"
bash "$plugins/cacert/install.sh"
bash "$plugins/shell/install.sh"
bash "$plugins/oh-my-zsh/install.sh"
bash "$plugins/git/install.sh"

# setting the installed version
cat "$babun/source/babun.version" > "$babun/installed/babun"