#!/bin/sh
#
# HOOK: remove:post
#
# Remove active container, when the container is removed
#

while [ $# -gt 0 ]
do
  case "$1" in
    -c|--container)
      container="${2}"
      shift
      ;;
    -*)
      echo >&2 "unknown flag $1 : stop [-c|--container] {container}"
      exit
      ;;
    *)
      break;
  esac
  shift
done

# Run the hook to remove the active container label
debug "HOOK : remove:post (010) ==> echo \"\" > ${path_container}"
echo "" > ${path_container}
