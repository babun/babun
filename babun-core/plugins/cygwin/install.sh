#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

src="$babun_source/babun-core/plugins/cygwin/src"
dest="$babun/home/pact/.pact"


/bin/cp -rf /bin/mkpasswd.exe /bin/mkpasswd.exe.current
/bin/cp -rf $src/bin/mkpasswd_1.7.29.exe /bin/mkpasswd.exe
chmod 755 /bin/mkpasswd.exe /bin
