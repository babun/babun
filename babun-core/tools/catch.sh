# Trap errors (commands exiting with a non-zero status)
trap 'catch_err ${LINENO}' ERR

function catch_err() {
  local PARENT_LINENO="$1"
  local MESSAGE="$2"
  local CODE="${3:-1}"
  if [[ -n "$MESSAGE" ]] ; then
    echo "Error on or near line ${PARENT_LINENO}: ${MESSAGE}; exiting with status ${CODE}"
  else
    echo "Error on or near line ${PARENT_LINENO}; exiting with status ${CODE}"
  fi
  exit "${CODE}"
}
