#!/bin/bash
trap 'previous_command="$this_command"; this_command="$BASH_COMMAND"' DEBUG
trap 'catch_err "${previous_command}" ${LINENO}' ERR

function catch_err() {
  local COMMAND="$1"
  local PARENT_LINENO="$2"
  local MESSAGE="$3"
  local CODE="${4:-1}"
  if [[ -n "$MESSAGE" ]] ; then
    echo "Error on or near line ${PARENT_LINENO}, last command '${COMMAND}' : ${MESSAGE};"
  else
    echo "Error on or near line ${PARENT_LINENO}, last command '${COMMAND}';"
  fi
}


