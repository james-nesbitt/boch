#!/bin/sh
#
# Configurable settings for the project
#

hook_version=2
hook_root="hook_settings_040"

# path to custom settings
path_customsettings="${path_data}/settings.sh"

# description method
hook_settings_040_description()
{
  echo "hook->settings 040 : include a project specific settings.sh"
}

# help method
hook_settings_040_help()
{
  echo "
hook->settings 040 : include a project specific settings.sh

"
}


# execute method
hook_settings_040_execute()
{

  # Allow skipping this custom file stuff
  ignore_root_custom_settings_file=${ignore_root_custom_settings_file:-0}

  if [ ${ignore_root_custom_settings_file} -eq 0 ]; then

    debug --level 8 --topic "HOOK->SETTINGS->040" "Importing all of the custom settings files : [all files:${path_customsettings}]"
    # try the default custom settings paths for includes
    if [ -n ${path_customsettings} ]; then
      for path in ${path_customsettings}; do
        if [ -f $path ]; then
          debug --level 6 --topic "HOOK->SETTINGS->040" "Importing custom settings file [file:${path}]"
          _include_source $path $@
        else
          debug --level 7 --topic "HOOK->SETTINGS->040" "Custom settings file not found: ${path}"
        fi
      done
    fi

  else
    # we were told to skip custom files
    debug --level 8 --topic "HOOK->SETTINGS->040" "Skipping importing custom settings files [${ignore_root_custom_settings_file}] : ${path_customsettings}"
  fi

}
