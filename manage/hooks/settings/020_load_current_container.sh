#!/bin/sh
#
# HOOK: settings
#
# Load any active containers into the active container file
#

# Default container file is currently optional.  It is created when saving the container the first time
#if !_create_empty_file ${path_container}; then
#debug --level 1 --topic "HOOK" "settings (020) :: Failed to create required active container file: $file"
#fi

if [ -f ${path_container} -a -s ${path_container} ]; then
  Docker_container="`cat ${path_container}`"
  debug "HOOK: settings (020) :: Loaded active container (from:${path_container}) id: ${Docker_container}"
fi
