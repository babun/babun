babun="/usr/local/etc/babun"
source "$babun/source/babun-core/tools/stamps.sh"

welcome_stamp="/usr/local/etc/babun/stamps/welcome"
if ! [ -f "$welcome_stamp" ]; then 
	babun --welcome
	echo ""
	echo "$(date)" > "$welcome_stamp"		
fi
