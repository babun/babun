# IMPORTANT NOTE!
# DO NOT MODIFY THIS FILE -> IT WILL BE OVERWRITTEN ON UPDATE
# If you want to some options modify the following file: ~/.bashrc
source /etc/profile
test -f "$homedir/.profile" && source "$homedir/.profile"
test -f "$homedir/.bash_profile" && source "$homedir/.bash_profile"
source "/usr/local/etc/babun.instance"

PS1="\[\033[00;34m\]{ \[\033[01;34m\]\W \[\033[00;34m\]}\[\033[01;32m\] \$( git rev-parse --abbrev-ref HEAD 2> /dev/null || echo "" ) \[\033[01;31m\]» \[\033[00m\]"

# overwrite values with user's local settings
test -f "$homedir/.babunrc" && source "$homedir/.babunrc"
