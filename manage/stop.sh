#!/bin/sh

# include docker settings and utilities
path_project="$(dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"
source ${path_project}/manage/_main.sh

# Run the run function
docker_stop
