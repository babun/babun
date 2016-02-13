#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

src="$babun_source/babun-core/plugins/cygfix/src"

# Fix for https://github.com/babun/babun/issues/455 (Git ntlm proxy issue)
echo "Fixing git-remote-http.exe"
/bin/cp -rf /usr/libexec/git-core/git-remote-http.exe /usr/libexec/git-core/git-remote-http.exe.current
/bin/cp -rf $src/bin/git-remote-http_2.1.4.exe /usr/libexec/git-core/git-remote-http.exe
chmod 755 /usr/libexec/git-core/git-remote-http.exe

echo "Fixing git-remote-https.exe"
/bin/cp -rf /usr/libexec/git-core/git-remote-http.exe /usr/libexec/git-core/git-remote-https.exe.current
/bin/cp -rf $src/bin/git-remote-https_2.1.4.exe /usr/libexec/git-core/git-remote-https.exe
chmod 755 /usr/libexec/git-core/git-remote-https.exe