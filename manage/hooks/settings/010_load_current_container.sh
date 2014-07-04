#!/bin/sh
#
# HOOK: settings
#
# Load any active containers into the active container file
#

if [ -f ${path_container} -a -s ${path_container} ]; then
  Docker_container="`cat ${path_container}`"
  debug "HOOK: settings:pre (010) :: Loaded active container (from:${path_container}) id: ${Docker_container}"
fi
