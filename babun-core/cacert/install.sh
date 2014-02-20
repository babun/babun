#!/bin/bash
set -o pipefail
set -e
set -f

# plugin descriptor
plugin_name=cacert
plugin_version=1
should_install_plugin


cd /usr/ssl/certs
curl http://curl.haxx.se/ca/cacert.pem | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".pem"}'
c_rehash