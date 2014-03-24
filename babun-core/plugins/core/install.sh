#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/plugins.sh"

# plugin descriptor
plugin_name=core
plugin_version=1
should_install_plugin


src="$babun/source/babun-core/plugins/core/src"

/bin/cp -rf $src/babun /usr/local/bin
chmod 755 /usr/local/bin/babun

/bin/cp -rf $src/babun.rc /usr/local/etc
source /usr/local/etc/babun.rc
/bin/cp -rf $src/babun.bash /usr/local/etc
/bin/cp -rf $src/babun.zsh /usr/local/etc
/bin/cp -rf $src/babun.start /usr/local/etc

mkdir -p "$babun/home/core"
/bin/cp -rf $src/.babunrc "$babun/home/core/.babunrc"


# instrument the shells with the babun config
profiles=("/etc/profile" "/etc/zprofile")
for profile in "${profiles[@]}"; do	
	if ! grep -Fxq "Installing babun" "$profile" ;then
		echo "Adding babun auto-install  -> $profile"
		sed -i 's/unset fDest/unset fDest\n    echo "Installing babun"\n    \/usr\/local\/etc\/babun\/source\/babun-core\/plugins\/install_home.sh/' "$profile"
	fi

done

profiles=("/etc/bash.bashrc")
for profile in "${profiles[@]}"; do	
	if ! grep -Fxq "source /usr/local/etc/babun.rc" "$profile" ;then
		echo "Supplementing shell with babun.rc -> $profile"
		echo "source /usr/local/etc/babun.rc" >> "$profile"
	fi

	if ! grep -Fxq "source /usr/local/etc/babun.bash" "$profile" ;then
		echo "Supplementing bash -> $profile"
		echo "source /usr/local/etc/babun.bash" >> "$profile"
	fi

	if ! grep -Fxq "source /usr/local/etc/babun.start" "$profile" ;then
		echo "Adding startup script -> $profile"
		echo "source /usr/local/etc/babun.start" >> "$profile"
	fi
done

if ! [ -f /etc/zshrc ]; then
	touch /etc/zshrc
	chmod 755 /etc/zshrc
fi

profiles=("/etc/zshrc")
for profile in "${profiles[@]}"; do	
	if ! grep -Fxq "source /usr/local/etc/babun.rc" "$profile" ;then
		echo "Supplementing shell with babun.rc -> $profile"
		echo "source /usr/local/etc/babun.rc" >> "$profile"
	fi

	if ! grep -Fxq "source /usr/local/etc/babun.bash" "$profile" ;then
		echo "Supplementing zsh -> $profile"
		echo "source /usr/local/etc/babun.zsh" >> "$profile"
	fi

	if ! grep -Fxq "source /usr/local/etc/babun.start" "$profile" ;then
		echo "Adding startup script -> $profile"
		echo "source /usr/local/etc/babun.start" >> "$profile"
	fi
done
