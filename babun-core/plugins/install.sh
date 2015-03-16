#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"

source "$babun_tools/script.sh"
source "$babun_tools/plugins.sh"

# prepare the environment
mkdir -p "$babun/home"
mkdir -p "$babun/external"
mkdir -p "$babun/installed"

# fix the symlinks if necessary
bash "$babun_tools/fix_symlinks.sh"

# install plugins
plugin_install "core"
plugin_install "pact"
plugin_install "cacert"
plugin_install "shell"
plugin_install "oh-my-zsh"
plugin_install "git"
plugin_install "cygdrive"
plugin_install "dist"
