set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

#uninstall registry keys
"$babun_plugins/shell-here/exec.sh" remove