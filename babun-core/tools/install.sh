#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

# prepare the environment
mkdir -p "$babun/home"
mkdir -p "$babun/external"
mkdir -p "$babun/installed"

# fix the links if necessary
if ! [ -f "/etc/postinstall/symlinks_repair.sh.done" ]; then
	echo "Fixing symlinks for the installation"
	dos2unix "/etc/postinstall/symlinks_repair.sh"
	chmod 755 "/etc/postinstall/symlinks_repair.sh"
	bash "/etc/postinstall/symlinks_repair.sh"
fi

# install plugins
bash "$babun/source/babun-core/cacert/install.sh"
bash "$babun/source/babun-core/pact/install.sh"
bash "$babun/source/babun-core/shell/install.sh"
bash "$babun/source/babun-core/babun/install.sh"
bash "$babun/source/babun-core/oh-my-zsh/install.sh"

# do the post-installation setup
# instrument the shells with the babun config
profiles=("/etc/profile" "/etc/zprofile" "/etc/defaults/etc/profile")
for profile in "${profiles[@]}"; do	
	
	if ! grep -Fxq "Installing babun" "$profile" ;then
		echo "Adding babun auto-install  -> $profile"
		sed -i 's/unset fDest/unset fDest\n    echo "Installing babun"\n    \/usr\/local\/etc\/babun\/source\/babun-core\/tools\/home.sh/' "$profile"
	fi

	if ! grep -Fxq "source /usr/local/etc/babun.rc" "$profile" ;then
		echo "Supplementing shell with babun.rc -> $profile"
		echo "source /usr/local/etc/babun.rc" >> "$profile"
	fi

	if ! grep -Fxq "source ~/.babunrc" "$profile" ;then
		echo "Supplementing shell with local .babunrc -> $profile"
		echo "source ~/.babunrc" >> "$profile"
	fi

done

profiles=("/etc/profile" "/etc/defaults/etc/profile")
for profile in "${profiles[@]}"; do	
	if ! grep -Fxq "source /usr/local/etc/babun.bash" "$profile" ;then
		echo "Supplementing bash -> $profile"
		echo "source /usr/local/etc/babun.bash" >> "$profile"
	fi
done

profiles=("/etc/zprofile")
for profile in "${profiles[@]}"; do	
	if ! grep -Fxq "source /usr/local/etc/babun.bash" "$profile" ;then
		echo "Supplementing zsh -> $profile"
		echo "source /usr/local/etc/babun.zsh" >> "$profile"
	fi
done
