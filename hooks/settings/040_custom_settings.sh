#!/bin/sh
#
# Configurable settings for the project
#

hook_version=2
hook_root="hook_settings_040"

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

  # path to this management system
  path_customsettings="$path_data/settings.sh"

  # Allow skipping this custom file stuff
  ignore_root_custom_settings_file=${ignore_root_custom_settings_file:-0}

  if [ ${ignore_root_custom_settings_file} -gt 0 ]; then

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

}
