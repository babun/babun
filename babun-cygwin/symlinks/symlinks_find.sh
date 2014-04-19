#!/bin/bash
set -e -f -o pipefail
/bin/find /bin /dev /etc /lib /sbin /usr /var -type l > /etc/postinstall/symlinks_broken.txt