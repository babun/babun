#!/bin/bash
#set -e -f -o pipefail -> don't use it, not required
/bin/find /bin /dev /etc /lib /usr /var -type l > /etc/postinstall/symlinks_broken.txt