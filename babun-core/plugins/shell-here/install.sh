set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

#start with installing chere
pact install chere || echo "Installing 'chere' failed. Please execute 'pact install chere' to fix it otherwise the plugin may not work."

#install registry keys
bash exec.sh init
