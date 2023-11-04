#!/bin/bash

# Initialize variables
version=""
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
    version=$1
    shift
  fi
done

# Get the list of releases
releases=$(fly releases --image $flags)

# If the version is HEAD^n format
if [[ $version == HEAD* ]]; then
  n=${version#HEAD^}
  docker_image=$(echo "$releases" | awk -v n="$n" 'NR == n+2 {print $NF}')
  status=$(echo "$releases" | awk -v n="$n" 'NR == n+2 {print $2}')
# If the version is vN format
else
  docker_image=$(echo "$releases" | awk -v version="$version" '$1 == version {print $NF}')
  status=$(echo "$releases" | awk -v version="$version" '$1 == version {print $2}')
fi

# Check if the release's status is complete
if [ "$status" != "complete" ]; then
  echo "Only complete releases can be reverted."
  exit 1
fi

# Deploy the docker image
fly deploy -i $docker_image $flags

# Log the rollback
echo "Rolled back to $version"
