#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

function check_only_one_running {
    if ! [ -d /var/lock ]; then
        mkdir -p /var/lock
    fi

    proc_name=$1
    if mkdir /var/lock/$proc_name 2>/dev/null ; then
        trap 'rm -rf "/var/lock/$proc_name"; exit $?' INT TERM EXIT
    else
        echo "You can only run one instance of $proc_name. Exiting!";
        exit 1;
    fi
}