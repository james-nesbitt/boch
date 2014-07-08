#!/bin/sh
#
# Configurable settings for the project
#

debug --level 4 --topic "HOOK" "settings (040) :: Importing custom settings from : ${path_settings}"

# try the default custom settings paths for includes
if [ -n ${path_settings} ]; then
  for path in ${path_settings}; do
  	if [ -f $path ]; then
	  debug --level 6 --topic "HOOK" "settings (040) :: Importing custom settings file : ${path}"
	  source $path $@
  	fi
  done
fi
