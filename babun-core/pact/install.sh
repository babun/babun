#!/bin/bash
set -o pipefail
set -e
set -f

PACT_SRC="~/.babun/babun-core/src"
PACT_HOME="~/.pact"

\cp -rf $PACT_SRC/pact /usr/local/bin
chmod 755 /usr/local/bin/pact

if [ ! -d "$PACT_HOME" ]; then
    mkdir "$PACT_HOME"
fi

if [ ! -f "$PACT_HOME/pact.repo" ]; then
    cp "$PACT_SRC/pact.repo" "$PACT_HOME"
fi