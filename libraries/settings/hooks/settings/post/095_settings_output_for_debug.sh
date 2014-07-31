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
    >SINGLE PATHS USED
    -->path_project----------: ${path_project}
    -->path_execution--------: ${path_execution}
    -->path_manage-----------: ${path_manage}
    -->path_data-------------: ${path_data}
    -->path_source-----------: ${path_source}
    >LIBRARIES
    -->path_libraries--------: ${path_libraries}
    -->libraries loaded------: ${included_libraries}
    >COMMANDS
    -->path_commands---------: ${path_commands}
    >HOOKS
    -->path_hooks------------: ${path_hooks}
    >PROJECT CONFIGURATION
    -->Project_name----------: ${project_name}
    >PROJECT DOCKER CONFIGURATIONS
    -->project_container-----: ${project_container}
    -->project_image---------: ${project_image}
    -->project_imageversion--: ${project_imageversion}
    >PROJECT MACHINE CONFIGURATIONS
    -->Machine_hostname------: ${machine_hostname}
    -->Machine_mountvolumes--: ${machine_mountvolumes}
    -->Machine_shell---------: ${machine_shell}
    -->Machine_shellrunargs--: ${machine_shellrunargs}
    -->Machine_runargs-------: ${machine_runargs}
  ] (hooks/settings/post/095)"
  fi

}
