#!/bin/bash
set -e -f -o pipefail

function set_reg_keys {

	local babun_root="$( cygpath -w "/" | sed "s#\\\cygwin##g" )"
	# the name that appears in the right-click context menu
	local icon="${babun_root}\cygwin\bin\mintty.exe"
	local name="Open in Babun"
	local background_name="Open Babun here"
	local cmd="${babun_root}\babun.bat \"%1\""
	local background_cmd="${babun_root}\babun.bat \"%V\""

	local keys=("HKCU\Software\Classes\Directory\shell\babun"
	"HKCU\Software\Classes\Drive\shell\babun")
	local background_keys=("HKCU\Software\Classes\Directory\Background\shell\babun"
	"HKCU\Software\Classes\Drive\Background\Shell\babun")

	#install registry keys
	for key in ${keys[*]}
	do
		cmd /c "reg" "add" "${key}" "/ve" "/d" "${name}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
		cmd /c "reg" "add" "${key}" "/v" "Icon" "/d" "${icon}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
		cmd /c "reg" "add" "${key}\command" "/ve" "/d" "${cmd}" "/t" "REG_EXPAND_SZ" "/f" || echo "Failed adding ${key}"
	done
	for key in ${background_keys[*]}
	do
		cmd /c "reg" "add" "${key}" "/ve" "/d" "${background_name}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
		cmd /c "reg" "add" "${key}" "/v" "Icon" "/d" "${icon}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
		cmd /c "reg" "add" "${key}\command" "/ve" "/d" "${background_cmd}" "/t" "REG_EXPAND_SZ" "/f" || echo "Failed adding ${key}"
	done
}

function unset_reg_keys {

	local keys=("HKCU\Software\Classes\Directory\Background\shell\babun"
	"HKCU\Software\Classes\Directory\shell\babun"
	"HKCU\Software\Classes\Drive\Background\Shell\babun"
	"HKCU\Software\Classes\Drive\shell\babun")

	#uninstall registry keys
	for key in ${keys[*]}
	do
		cmd /c "reg" "delete" "${key}" "/f" || echo "Failed deleting ${key}"
	done

}


if [ "$1" == "init" ]; then
	set_reg_keys
elif [ "$1" == "remove" ]; then
	unset_reg_keys
elif [ "$1" == "" ]; then
	echo "Missing argument. Use 'init' or 'remove' option."
else
	echo "Invalid option $1. Valid options are 'init' and 'remove'."
fi
