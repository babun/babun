#!/bin/bash
set -e -f -o pipefail

# init babun.instance before anything other initializes
/bin/cp -rf /usr/local/etc/babun/source/babun-core/plugins/core/src/babun.instance /usr/local/etc
