#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

# prepare the environment
mkdir -p "$babun/home"
mkdir -p "$babun/external"
mkdir -p "$babun/installed"

# fix the symlinks if necessary
bash "$babun/source/babun-core/tools/fix_symlinks.sh"

# install plugins
bash "$babun/source/babun-core/core/install.sh"
bash "$babun/source/babun-core/pact/install.sh"
bash "$babun/source/babun-core/cacert/install.sh"
bash "$babun/source/babun-core/shell/install.sh"
bash "$babun/source/babun-core/oh-my-zsh/install.sh"

# pre-configure git
bash "$babun/source/babun-core/tools/git.sh"

# setting the installed version
cat "$babun/source/babun.version" > "$babun/installed/babun"