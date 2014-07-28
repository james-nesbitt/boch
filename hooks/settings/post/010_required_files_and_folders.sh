#!/bin/sh
#
# Make sure that we have the folders and files that we need
#

debug --level 4 --topic "HOOK" "settings/post (010) :: Create required folders and files for operation"

#
# This process is kind of manual, but has a bit of automation
# in it.  Some elements are really necessary, but some should
# be overridable.  This script handles all of the overridable
# elements (after discovery I realized that this is all them)
#

#
# Required Folders
#
required_folders="${required_folders} ${path_data}"
for path in $required_folders
do
  if ! _ensure_folder $path; then
    debug --level 1 --topic "HOOK" "settings/post (010) :: Failed to create required folder: $path"
  else
  	debug --level 8 --topic "HOOK" "settings/post (010) :: Created required folder: $path"
  fi
done

#
# Required Files
#
required_files="${required_files} ${path_log}"
for file in $required_files
do
  if ! _ensure_file $file; then
    debug --level 1 --topic "HOOK" "settings/post (010) :: Failed to create required file: $file"
  else
  	debug --level 8 --topic "HOOK" "settings/post (010) :: Created required file: $file"
  fi
done
