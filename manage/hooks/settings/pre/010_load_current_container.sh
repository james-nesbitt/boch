#!/bin/sh
#
# HOOK: global:pre
#
# Load any active containers into the 
#

if [ -f ${path_container} -a -s ${path_container} ]; then
  Docker_container="`cat ${path_container}`"
  debug "HOOK: settings:pre (010) : Running settings:pre hooks => Loaded active container (from:${path_container}) id: ${Docker_container}"
fi
