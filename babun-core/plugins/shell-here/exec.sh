#!/bin/bash
set -e -f -o pipefail

declare -A translations
translations[en-US]="Open Comm&and Prompt"
translations[en-US-admin]="Open E&levated Command Prompt"
translations[de-DE]="Einga&beaufforderung öffnen"
translations[de-DE-admin]="Einga&beaufforderung öffnen (Administrator)"
translations[es-ES]="A&brir un símbolo del sistema"
translations[es-ES-admin]="A&brir un símbolo del sistema (Administrador)"
translations[fr-FR]="Ouvrir une &invite de commandes"
translations[fr-FR-admin]="Ouvrir une &invite de commandes (Administrateur)"
translations[it-IT]="Apri un prompt &dei comandi"
translations[it-IT-admin]="Apri un prompt &dei comandi (Amministratore)"

function set_reg_keys {

	local babun_root="$( cygpath -w "/" | sed "s#\\\cygwin##g" )"
	local mintty="${babun_root}\cygwin\bin\mintty.exe"
	local keys=("HKCU\Software\Classes\Directory\Background\shell\babun"
	"HKCU\Software\Classes\Directory\shell\babun"
	"HKCU\Software\Classes\Drive\Background\Shell\babun"
	"HKCU\Software\Classes\Drive\shell\babun")
	local vbs="${babun_root}\tools\shell-here.vbs"

	# get system language
	local language=`reg query "HKCU\Control Panel\Desktop" /v PreferredUILanguages | findstr PreferredUILanguages | awk '{ print $3 }'`
	if [ -z $language ]; then
		language="en-US"
	fi

	# the name that appears in the right-click context menu
	local name=""
	local nameAdmin=""

	# use translated name for context menu
	for key in ${!translations[@]}; do
		if [ "$key" = "$language" ]; then
			name=${translations[$key]}
		fi
		if [ "$key" = "$language-admin" ]; then
			nameAdmin=${translations[$key]}
		fi
	done

	echo '' > "${vbs}"
	echo 'If WScript.Arguments.Count = 1 Then' >> "${vbs}"
	echo '	If Wscript.Arguments(0) = "/admin" Then' >> "${vbs}"
	echo '		Invoke "", "runas"' >> "${vbs}"
	echo '	Else' >> "${vbs}"
	echo '		Invoke Wscript.Arguments(0), ""' >> "${vbs}"
	echo '	End if' >> "${vbs}"
	echo 'ElseIf WScript.Arguments.Count = 2 Then' >> "${vbs}"
	echo '	If Wscript.Arguments(1) = "/admin" Then' >> "${vbs}"
	echo '		Invoke Wscript.Arguments(0), "runas"' >> "${vbs}"
	echo '	Else' >> "${vbs}"
	echo '		Invoke Wscript.Arguments(0), ""' >> "${vbs}"
	echo '	End if' >> "${vbs}"
	echo 'Else' >> "${vbs}"
	echo '	Invoke "", ""' >> "${vbs}"
	echo 'End If' >> "${vbs}"
	echo 'Function CutBackslash(path)' >> "${vbs}"
	echo '	CutBackslash = path' >> "${vbs}"
	echo '	If Right(path, 1) = "\" Then' >> "${vbs}"
	echo '		CutBackslash = Left(path, Len(path) - 1)' >> "${vbs}"
	echo '	End If' >> "${vbs}"
	echo 'End Function' >> "${vbs}"
	echo 'Sub Invoke(path, verb)' >> "${vbs}"
	echo '	Set app = CreateObject("Shell.Application")' >> "${vbs}"
	echo '	app.ShellExecute "'${mintty}'", "/bin/env CHERE_INVOKING=1 INVOKE_CD=" & Chr(34) & CutBackslash(path) & Chr(34) & " /bin/zsh", "", verb, 1' >> "${vbs}"
	echo 'End Sub' >> "${vbs}"

	# install registry keys
	for key in ${keys[*]}
	do
		cmd /c "reg" "add" "${key}" "/ve" "/d" "${name}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
		cmd /c "reg" "add" "${key}" "/v" "Icon" "/d" "${mintty}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
		cmd /c "reg" "add" "${key}\command" "/ve" "/d" "wscript.exe ${vbs} \"%V\"" "/t" "REG_EXPAND_SZ" "/f" || echo "Failed adding ${key}"

		cmd /c "reg" "add" "${key}_admin" "/ve" "/d" "${nameAdmin}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
		cmd /c "reg" "add" "${key}_admin" "/v" "Icon" "/d" "${mintty}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
		cmd /c "reg" "add" "${key}_admin\command" "/ve" "/d" "wscript.exe ${vbs} \"%V\" /admin" "/t" "REG_EXPAND_SZ" "/f" || echo "Failed adding ${key}"
	done
}

function unset_reg_keys {

	local keys=("HKCU\Software\Classes\Directory\Background\shell\babun"
	"HKCU\Software\Classes\Directory\shell\babun"
	"HKCU\Software\Classes\Drive\Background\Shell\babun"
	"HKCU\Software\Classes\Drive\shell\babun")

	#install registry keys
	for key in ${keys[*]}
	do
		cmd /c "reg" "delete" "${key}" "/f" || echo "Failed deleting ${key}"
		cmd /c "reg" "delete" "${key}_admin" "/f" || echo "Failed deleting ${key}"
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
