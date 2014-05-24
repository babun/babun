#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"

source "$babun_tools/script.sh"
src="$babun_source/babun-core/plugins/core/src"

/bin/cp -rf $src/babun /usr/local/bin
chmod 755 /usr/local/bin/babun

/bin/cp -rf $src/babun.rc /usr/local/etc
source /usr/local/etc/babun.rc
/bin/cp -rf $src/babun.bash /usr/local/etc
/bin/cp -rf $src/babun.zsh /usr/local/etc
/bin/cp -rf $src/babun.start /usr/local/etc
/bin/cp -rf $src/babun.instance /usr/local/etc

mkdir -p "$babun/home/core"
/bin/cp -rf $src/.babunrc "$babun/home/core/.babunrc"


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

