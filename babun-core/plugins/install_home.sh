#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun/source/babun-core/tools/script.sh"
source "$babun/source/babun-core/tools/plugins.sh"

# install home folder content
plugin_install_home "cacert"
plugin_install_home "core"
plugin_install_home "git"
plugin_install_home "oh-my-zsh"
plugin_install_home "pact"
plugin_install_home "shell"
