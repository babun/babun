#!/bin/bash
source "/usr/local/etc/babun.instance"

push=$(git config --global push.default || echo "")
if [[ "$push" != "" && "$push" != "tracking" && "$push" != "matching" && "$push" != "current" ]]; then
    echo "WARNING: Git push strategy set to 'simple' which is unsupported - changing to 'matching'"
    git config --global push.default "matching" || echo "ERROR: Cannot set git push.default to 'matching' - may cause problems..."
fi