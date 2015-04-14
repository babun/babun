#!/bin/bash

# Rename cygwin ping to fallback to Windows ping.exe as work-around for administrative privileges required for cygwin ping 

ping='/usr/bin/ping.exe'
cygping='/usr/bin/cygping.exe'

if [ ! -f $cygping ]; then
    mv $ping $cygping
fi
