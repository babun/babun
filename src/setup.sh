#/bin/bash
#
# The script changes are supposed to be idempotent! Please comply!
# 
echo "Setting up babun!"

#functions
function contains {
	return $(( grep -Fxq "$1" $2 ))
}

# babun config folder
if [ ! -d /etc/babun ]; then
	mkdir /etc/babun
fi

# bark config file
if [ ! -f /etc/babun/bark.conf ]; then
    touch /etc/babun/bark.conf
fi

# babun config file
if [ ! -f /etc/babun/babun.conf ]; then
    touch /etc/babun/babun.conf
fi

# make bark executable
chmod +x /usr/local/bin/bark

exit 0