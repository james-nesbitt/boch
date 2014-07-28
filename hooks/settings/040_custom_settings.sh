#!/bin/sh
#
# Configurable settings for the project
#

# path to this management system
path_customsettings="$path_project/settings.sh"

# Allow skipping this custom file stuff
ignore_root_custom_settings_file=${ignore_root_custom_settings_file:-0}

if [ ${ignore_root_custom_settings_file} -gt 0 ]; then

  debug --level 4 --topic "HOOK" "settings (040) :: Checking for custom settings file : ${path_customsettings}"

  # try the default custom settings paths for includes
  if [ -n ${path_customsettings} ]; then
    for path in ${path_customsettings}; do
	  if [ -f $path ]; then
	    debug --level 6 --topic "HOOK" "settings (040) :: Importing custom settings file : ${path}"
	    source $path $@
	  fi
    done
  fi

fi
