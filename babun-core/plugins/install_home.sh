#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"
source "$babun_tools/plugins.sh"

# install home folder content
plugin_install_home "dist"
plugin_install_home "core"
plugin_install_home "cygfix"
plugin_install_home "shell"
plugin_install_home "pact"
plugin_install_home "cacert"
plugin_install_home "oh-my-zsh"
plugin_install_home "git"
plugin_install_home "cygdrive"
plugin_install_home "ack"
plugin_install_home "shell-here"
