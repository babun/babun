#!/bin/bash
set -o pipefail
set -e
set -f

/bin/dos2unix.exe /etc/postinstall/symlinks_repair.sh
/etc/postinstall/symlinks_repair.sh
/bin/mv.exe /etc/postinstall/symlinks_repair.sh /etc/postinstall/symlinks_repair.sh.done

/bin/rm -rf /home/*
/bin/mkpasswd.exe -l -c >> /etc/passwd
/bin/mkgroup -l -c >> /etc/group
