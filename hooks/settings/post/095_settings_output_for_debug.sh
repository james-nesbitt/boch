#!/bin/sh
#
# Output the settings to screen if the debug level is high enough
#

hook_version=2
hook_root="hook_settings_post_095"

# description method
hook_settings_post_095_description()
{
  echo "hook->settings (post) 095 : output some debug values of important variables"
}

# help method
hook_settings_post_095_help()
{
  echo "
hook->settings (post) 095 : output some debug values of important variables

"
}

# execute method
hook_settings_post_095_execute()
{

  if [ $debug -gt 3 ]; then
    echo "
  CONFIG: final control settings: [
    >PATHS USED
    -->path_project:${path_project}
    -->path_execution:${path_execution}
    -->path_manage:${path_manage}
    -->path_settings:${path_settings}
    -->path_build:${path_build}
    -->path_commands:${path_commands}
    -->path_flows:${path_flows}
    -->path_hooks:${path_hooks}
    -->path_data:${path_data}
    -->path_source:${path_source}
    >PROJECT CONFIGURATION
    -->Project_name:${Project_name}
    >DOCKER CONFIGURATIONS
    -->Docker_container:${Docker_container}
    -->Docker_builds:${Docker_builds}
    -->Docker_image:${Docker_image}
    -->Docker_imageversion:${Docker_imageversion}
    >MACHINE CONFIGURATIONS
    -->Machine_hostname:${Machine_hostname}
    -->Machine_mountvolumes:${Machine_mountvolumes}
    -->Machine_shell:${Machine_shell}
    -->Machine_shellrunargs:${Machine_shellrunargs}
    -->Machine_runargs:${Machine_runargs}
  ] (hooks/settings/post/095)"
  fi

}