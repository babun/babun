#!/bin/bash
stamps="/usr/local/etc/babun/stamps"

if ! [ -d "$stamps" ]; then 
	mkdir -p "$stamps"
fi
