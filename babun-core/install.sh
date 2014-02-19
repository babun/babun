#!/bin/bash
set -o pipefail
set -e
set -f

babun="/usr/local/etc/babun"

mkdir "$babun/home"
mkdir "$babun/external"

echo "Executing pact/install.sh"
bash "$babun/source/babun-core/pact/install.sh"

echo "Executing shell/install.sh"
bash "$babun/source/babun-core/shell/install.sh"

echo "Executing babun/install.sh"
bash "$babun/source/babun-core/babun/install.sh"

echo "Executing oh-my-zsh/install.sh"
bash "$babun/source/babun-core/oh-my-zsh/install.sh"
