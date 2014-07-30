#!/bin/sh
#
# Configurable settings for the project
#
# @todo : move some of this to yaml?

hook_version=2
hook_root="hook_settings_030"

# description method
hook_settings_030_description()
{
  echo "hook->settings 030 : default variable values"
}

# help method
hook_settings_030_help()
{
  echo "
hook->settings 030 : default variable values

"
}

# execute method
hook_settings_030_execute()
{

  debug --level 4 --topic "HOOK" "settings (030) :: Importing default settings"

  # General project name, should be file-safe
  Project_name="${Project_name:-${path_project##*/}}"

  # Docker build images
  # Generally needed to start making containers (a space separated queue of builds)
  # and are the default builds built with the build command.
  Docker_builds="${Docker_builds:-"wwwserver-cnpm wwwserver-cnpm-dev project"}"
  # The docker image, which will be used for containers, (and building)
  Docker_image="${Docker_image:-${Docker_builds##* }}"
  # by default all containers will run from the base image, which is created by build, however maybe we want to use a different version for advanced features
  Docker_imageversion="${Docker_imageversion:-"latest"}" # Used for run/shell/commit
  # use a default container name, default to a combination of image and version
  Docker_container=${Docker_container:-${Docker_image}_${Docker_imageversion}}


  # hostname used inside the running container
  Machine_hostname="${Machine_hostname:-$Docker_container}"

  # Prefered shell/command for the Machine : bash is pretty safe, but we probably have zsh installed.  the custom settings defaults include zsh.
  Machine_shell=${Machine_shell:-"/bin/bash"}

  # Default running args
  Machine_runargs=${Machine_runargs:-""}
  # default run args for shell command
  Machine_shellrunargs=${Machine_shellrunargs:-"--publish-all=true"}

  # live mounts that are used for containers
  path_source="${path_project}/source"
  _ensure_folder $path_source

  if [ $? == 0 ]; then
    debug --level 8 --topic "HOOK" "settings (030) :: Created required folder for project source code, adding it to the mount path list: $path_source"
    Machine_mountvolumes="${Machine_mountvolumes} --volume=${path_source}:/app/source"
  else
    debug --level 3 --topic "HOOK" "settings (030) :: Failed to create required folder for project source code path: $path_source"
  fi

}
