#!/bin/bash
# IMPORTANT NOTE!
# DO NOT MODIFY THIS FILE -> IT WILL BE OVERWRITTEN ON UPDATE
# If you want to some options modify the following file: ~/.zshrc
source /etc/zprofile
test -f "$homedir/.zprofile" && source "$homedir/.zprofile"
source "/usr/local/etc/babun.instance"

# overwrite values with user's local settings
test -f "$homedir/.babunrc" && source "$homedir/.babunrc"
