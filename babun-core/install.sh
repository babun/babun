#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

mkdir -p "$babun/home"
mkdir -p "$babun/external"

echo "Fixing symlinks for the installation"
dos2unix "/etc/postinstall/symlinks_repair.sh"
chmod 755 "/etc/postinstall/symlinks_repair.sh"
bash "/etc/postinstall/symlinks_repair.sh"

echo "Executing cacert/install.sh"
bash "$babun/source/babun-core/cacert/install.sh"

echo "Executing pact/install.sh"
bash "$babun/source/babun-core/pact/install.sh"

echo "Executing shell/install.sh"
bash "$babun/source/babun-core/shell/install.sh"

echo "Executing babun/install.sh"
bash "$babun/source/babun-core/babun/install.sh"

echo "Executing oh-my-zsh/install.sh"
bash "$babun/source/babun-core/oh-my-zsh/install.sh"

echo "Adding babun home folder auto-install"
profiles=("/etc/profile" "/etc/zprofile" "/etc/defaults/etc/profile")
for profile in "${profiles[@]}"; do	
	if ! grep -Fxq "Installing babun" "$profile" ;then
		echo "  -> $profile"
		sed -i 's/unset fDest/unset fDest\n    echo "Installing babun"\n    \/usr\/local\/etc\/babun\/source\/babun-core\/home.sh/' "$profile"
	fi
done
