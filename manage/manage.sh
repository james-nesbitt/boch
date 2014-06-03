#!/bin/sh

# Some hardcoded stuff to let us call the script from elsewhee
path_project="$(dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"

# get some paths
path_execution=`pwd`
path_conf="$path_project/conf"
path_manage="$path_project/manage"
path_settings="$path_manage/_settings.sh"
path_containterID="$path_conf/_container"

# Comman control
vflag=off
debug=0

# include docker settings and utilities
source ${path_manage}/_settings.sh

# Overridable settings for docker and the machine
Project_name="${Project_name:-${path_project##*/}}"
Docker_image="${Docker_image:-$Project_name}"
[ -z "${Docker_container}" ] && Docker_container="`cat ${path_containterID}`"
Machine_hostname="${Machine_hostname:-$Docker_container}"

# include docker functions
source ${path_manage}/_docker.sh

#
# Process Global Arguments and find the COMMAND
#

while [ $# -gt 0 ]
do
  case "$1" in
    -v|--verbose)  vflag=on; debug=1;;
    -*)
        echo >&2 "usage: $0 [-v] [command ...]"
        exit 1;;
    *)
        COMMAND=$1
        shift
        break;; # terminate while loop
  esac
  shift
done

# print some debug info
if [ "$debug" == "1" ]; then
  echo "path_execution:${path_execution}"
  echo "path_conf:${Project_name}"
  echo "path_manage:${path_manage}"
  echo "path_settings:${path_settings}"
  echo "path_containterID:${path_containterID}"
  echo "Docker_container:${Docker_container}"
  echo "Docker_image:${Docker_image}"
  echo "Machine_hostname:${Machine_hostname}"
  echo "Command:${COMMAND}"
  echo "Command Args:${@}"
fi

#
# Process command : pass the rest of the arguments in
#
case "$COMMAND" in
    build)
      # Run the build function
      docker_build $@
      ;;

    start)
      # Run the build function
      docker_start $@
      ;;

    stop)
      # Run the build function
      docker_stop $@
      ;;

    shell)
      # Run the build function
      docker_shell $@
      ;;

esac