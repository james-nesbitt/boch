#!/bin/sh
#
# HOOK: start:run_post
#
# Remove active container, when the container is removed
#
# A local callback for saving container IDs
# @NOTE This is a pretty limited tool, but is
# the only iteration that we need until a better
# ID management system is designed
#
# -c|--container {container} : ID of new container
# -i|--image {image} : docker image used
# -n|--name {name} : container name if assigned
# -v|--version {version} : docker image version used
#
# @TODO Parameter validation
#

# default flags
flags=""
while [ $# -gt 0 ]
do
  case "$1" in
    -c|--container)
      container="${2}"
      shift
      ;;
    -n|--name)
      name="${2}"
      shift
      ;;
    -i|--image)
      image="${2}"
      shift
      ;;
    -v|--version)
      version="${2}"
      shift
      ;;
    *)
        break;; # terminate while loop
  esac
  shift
done

# Write the container ID to the container file
debug --level 4 --topic "HOOK" "start:run_post (010) :: saving new container to active [image:${image}][version:${version}][container:${container}][name:${name}] ==> echo ${name:-container} > ${path_container}"
echo ${name:-container} > ${path_container}
