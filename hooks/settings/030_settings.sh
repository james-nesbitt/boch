#!/bin/sh
#
# Configurable settings for the project
#
# @todo : move some of this to yaml?

debug --level 4 --topic "HOOK" "settings (030) :: Importing custom settings"

# Overrideable configuration variables
#Project_name="project"

# Default docker image created in build, used in start/run/shell
#Docker_image="project" # The image name which will then be used by docker
#Docker_imageversion="latest" # you can implements branching using versions, where a version is like a fork

# Docker container ID, used for start/stop/run etc
#Docker_container="project_server"

# OS hostname used inside the container (which would impact things like avahi)
#Machine_hostname="${Project_name}"

# Prefered shell configuration for the Machine
# Running as a shell is a temporary approach to getting shell access to a machine
# but should be considered secondary to other methods of running commands on the
# container.  It is a good plan for now but will be dropped in the future.
#
# @NOTE Running a shell creates a new container, and does not give access to an existing container
Machine_shell="/bin/zsh"
# arguments for docker run that should always be included when starting a shell: docker help run
Machine_shellrunargs="--publish-all=true --env HOME=/home/developer --user=developer"

# Machine arguments for regular container runs.  These arguments are added to all runs (except shell runs)
Machine_runargs="--tty" # --tty is needed for supervisord to run.

# Build Mount list:
#
# These are run time mounts, where the host FS can be changed
# diirectly changing the container FS.
#
# @TODO get away from having to include the -v flag here, by finding a better format for this
#

# Add our project source to the box
# @NOTE these folders assume we are using the default www root, and nginx conf.  Change this if you want to customize.
path_source="${path_project}/source"
path_source_www="${path_source}/www"
debug --level 6 --topic "HOOK" "settings (030) :: Making sure that we have the project source path \"${path_source_www}\""
if ! _ensure_folder ${path_source_www}; then
  debug --level 1 --topic "HOOK" "settings (015) :: Required webroot folder \"${path_source_www}\".  If this path isn't required in your project, then remove it's dependency from the 030_settings.sh hook in manage/hooks/settings"
fi
# Now that we have tested it, add the source folder to the mount
Machine_mountvolumes="${Machine_mountvolumes} --volume=${path_project}/source:/app/source"

# Mount the external user .ssh folder in the developer user home directory.
Machine_mountvolumes="${Machine_mountvolumes} --volume=${path_userhome}/.ssh:/home/developer/.ssh-host"
