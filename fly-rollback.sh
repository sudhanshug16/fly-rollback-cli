#!/bin/bash

function parse_arguments() {
  # Initialize variables
  values=()
  # any extra flags that need to be passed to fly
  flags=""

  # Parse the arguments
  while (( "$#" )); do
    if [[ $1 == -* ]]; then
      if [[ $2 && $2 != -* ]]; then
        flags="$flags $1 $2"
        shift 2
      else
        flags="$flags $1"
        shift
      fi
    else
      values+=("$1")
      shift
    fi
  done
}

function get_releases() {
  # Get the list of releases
  releases=$(fly releases --image $flags)
}

function get_version_and_status() {
  version=${values[0]}
  echo "version: $version"
  # If the version is HEAD^n format
  if [[ $version == HEAD* ]]; then
    n=${version#HEAD^}
    if [ "$n" -eq 0 ]; then
      echo "Error: Current release can't be rolled back to itself."
      exit 1
    fi
    docker_image=$(echo "$releases" | awk -v n="$n" 'NR == n+2 {print $NF}')
    status=$(echo "$releases" | awk -v n="$n" 'NR == n+2 {print $2}')
  # If the version is vN format
  else
    docker_image=$(echo "$releases" | awk -v version="version" '$1 == version {print $NF}')
    status=$(echo "$releases" | awk -v version="version" '$1 == version {print $2}')
  fi
}

function check_status_and_deploy() {
  # Check if the release's status is complete
  if [ "$status" != "complete" ]; then
    echo "Only complete releases can be reverted."
    exit 1
  fi

  # Deploy the docker image
  fly deploy -i $docker_image $flags
}

function log_rollback() {
  # Log the rollback
  echo "Rolled back to $version"
}

function list_releases() {
  # Add a HEAD^n column to the start of all the rows
  IFS=$'\n'
  head_counter=-1
  for release in $releases; do
    if [ $head_counter -eq -1 ]; then
      head_value="HEAD^n"
    elif [ $head_counter -eq 0 ]; then
      head_value="CURRENT"
    else
      head_value="HEAD^$head_counter"
    fi
    # Fix each cell in column to 10 characters to preserve the table
    printf "%-10s %s\n" $head_value $release
    ((head_counter++))
  done
  unset IFS
}

if [[ $1 == "list" ]]; then
  parse_arguments "$@"
  get_releases
  list_releases
else
  parse_arguments "$@"
  get_releases
  get_version_and_status
  check_status_and_deploy
  log_rollback
fi

