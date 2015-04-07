set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

babun_root=$( cygpath -w "/" | sed "s#\\\cygwin##g" )
name="Babun Shell here"
cmd="${babun_root}\cygwin\bin\mintty.exe -e /bin/xhere /bin/zsh.exe"

echo $cmd

keys=("HKCU\Software\Classes\Directory\Background\shell\babun"
	"HKCU\Software\Classes\Directory\shell\babun"
	"HKCU\Software\Classes\Drive\Background\Shell\babun"
	"HKCU\Software\Classes\Drive\shell\babun")

#start with installing chere
pact install chere || echo "Installing 'chere' failed"

#install registry keys
for key in ${keys[*]}
do 
	cmd /c "reg" "add" "${key}" "/ve" "/d" "${name}" "/t" "REG_SZ" "/f" || echo "Failed adding ${key}"
	cmd /c "reg" "add" "${key}\command" "/ve" "/d" "${cmd}" "/t" "REG_EXPAND_SZ" "/f" || echo "Failed adding ${key}"
done