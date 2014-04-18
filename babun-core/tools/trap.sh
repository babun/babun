#!/bin/bash
trap 'catch_err ${LINENO}' ERR

function catch_err() {
  local PARENT_LINENO="$1"
  local MESSAGE="$2"
  local CODE="${3:-1}"
  if [[ -n "$MESSAGE" ]] ; then
    echo "Error on or near line ${PARENT_LINENO}: ${MESSAGE};"
  else
    echo "Error on or near line ${PARENT_LINENO};"
  fi
}
