#!/bin/sh
#
# Make sure that we have the folders and files that we need
#

hook_version=2
hook_root="hook_settings_post_010"

# description method
hook_settings_post_010_description()
{
  echo "hook->settings:pre 010: create some core files and folders"
}

# help method
hook_settings_post_010_help()
{
  echo "
hook->settings:pre 010 : create some core files and folders

"
}

# execute method
hook_settings_post_010_execute()
{

  #
  # This process is kind of manual, but has a bit of automation
  # in it.  Some elements are really necessary, but some should
  # be overridable.  This script handles all of the overridable
  # elements (after discovery I realized that this is all them)
  #

  #
  # Required Folders
  #
  required_folders=""
  for path in "${required_folders}"
  do
    if [ "$path" != "" ]; then

      _ensure_folder $path
      success=$?

      if [ $success -gt 0 ]; then
	debug --level 3 --topic "HOOK->SETTINGS->POST->010" "Failed to create required folder: $path"
      else
	debug --level 8 --topic "HOOK->SETTINGS->POST->010" "Created required folder: $path"
      fi

    fi
  done

  #
  # Required Files
  #
  required_files="${required_files} ${path_log}"
  for file in "${required_files}"
  do
    if [ "$file" != "" ]; then

      debug --level 7 --topic "HOOK->SETTINGS->POST->010" "Creating required file: $file"
     _ensure_file $file;
     success=$?
     if [ $success -gt 0 ]; then
	debug --level 3 --topic "HOOK->SETTINGS->POST->010" "Failed to create required file: $file"
     else
	debug --level 7 --topic "HOOK->SETTINGS->POST->010" "Created required file: $file"
     fi

    fi
  done

}
