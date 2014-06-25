#!/bin/bash
# println babun welcome message
source "/usr/local/etc/babun.instance"

﻿find "$babun_plugins" -name 'start.sh' -exec bash '{}' || echo "Could not start " '{}' \;