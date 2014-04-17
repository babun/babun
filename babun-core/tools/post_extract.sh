#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun/source/babun-core/tools/script.sh"

/bin/dos2unix.exe /etc/postinstall/symlinks_repair.sh
/etc/postinstall/symlinks_repair.sh
/bin/mv.exe /etc/postinstall/symlinks_repair.sh /etc/postinstall/symlinks_repair.sh.done

/bin/rm -rf /home
/bin/mkpasswd.exe -l -c >> /etc/passwd
/bin/mkgroup -l -c >> /etc/group
