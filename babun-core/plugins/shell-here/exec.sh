#!/bin/bash
set -e -f -o pipefail

function set_reg_keys {

	local babun_root=$( cygpath -w "/" | sed "s#\\\cygwin##g" )
	local name="Babun Shell here"
	local cmd="${babun_root}\cygwin\bin\mintty.exe /bin/env CHERE_INVOKING=1 /bin/zsh.exe"

	local keys=("HKCU\Software\Classes\Directory\Background\shell\babun"
	"HKCU\Software\Classes\Directory\shell\babun"
	"HKCU\Software\Classes\Drive\Background\Shell\babun"
	"HKCU\Software\Classes\Drive\shell\babun")

	#install registry keys
	for key in ${keys[*]}
	do 
		cmd /c "reg" "add" "${key}" "/ve" "/d" "${name}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
		cmd /c "reg" "add" "${key}\command" "/ve" "/d" "${cmd}" "/t" "REG_EXPAND_SZ" "/f" || echo "Failed adding ${key}"
	done

}


if [ "$1" != "init" ]; then
	echo "Invalid option $1"
else 
	set_reg_keys
fi
