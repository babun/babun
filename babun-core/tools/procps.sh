#!/bin/bash
# set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
# does not work with pact - it's unnecessary anyway
# source "$babun_tools/script.sh"

function check_only_one_running {
    if ! [ -d /var/lock ]; then
        mkdir -p /var/lock
    fi

    proc_name=$1
    if mkdir /var/lock/$proc_name 2>/dev/null ; then
        trap 'rm -rf "/var/lock/$proc_name"; exit $?' INT TERM EXIT
    else
        echo "You can run only one instance of $proc_name. Close all other instances of $proc_name or remove the /var/lock/$proc_name/ directory if you are sure there are no other instances currently running.";
        exit 1;
    fi
}

function proc_exec_on_script_finish_trap {
    rm -rf "/var/lock/$proc_name";
}

function proc_shell_login {
    currshell=$( awk "/^$USERNAME/ { print $1 }" /etc/passwd | grep -oh "/bin/.*sh" )
    if ! [[ $currshell == "" ]]; then
        echo Login to default shell $currshell
        proc_exec_on_script_finish_trap
        exec $currshell
    else
        echo Could not login to default shell >&2
        exit 1
    fi
}
