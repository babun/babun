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

echo "[babun] HOME set to $HOME"

if [[ ! "$HOME" == /cygdrive* ]]; then
	echo "[babun] Running mkpasswd for CYGWIN home"
	# regenerate users' info
	/bin/mkpasswd.exe -l -c > /etc/passwd	

	# remove spaces in username and user home folder (sic!)
	# xuser=${USERNAME//[[:space:]]}
	# xhome="\/home\/"
	# /bin/sed -e "s/$USERNAME/$xuser/" -e "s/$xhome$USERNAME/$xhome$xuser/" -i /etc/passwd
else
	echo "[babun] Running mkpasswd for WINDOWS home"
	# regenerate users' info using windows paths
	/bin/mkpasswd -l -p "$(/bin/cygpath -H)" > /etc/passwd
fi
/bin/mkgroup -l -c > /etc/group

# fix file permissions in /usr/local
/bin/chmod 755 -R /usr/local
