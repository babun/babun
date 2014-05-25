#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

# fix symlinks on local instance
/bin/dos2unix.exe /etc/postinstall/symlinks_repair.sh
/etc/postinstall/symlinks_repair.sh
/bin/mv.exe /etc/postinstall/symlinks_repair.sh /etc/postinstall/symlinks_repair.sh.done

# regenerate user/group information
/bin/rm -rf /home
/bin/mkpasswd.exe -l -c > /etc/passwd

/bin/mkgroup -l -c > /etc/group

# remove spaces in username and user home folder (sic!)
xuser=${USERNAME//[[:space:]]}
xhome="\/home\/"
/bin/sed -e "s/$USERNAME/$xuser/" -e "s/$xhome$USERNAME/$xhome$xuser/" -i /etc/passwd

# fix file permissions
/bin/chmod 755 -R /usr/local
/bin/sed -e "s/binary,/binary,noacl,/" -i /etc/fstab
