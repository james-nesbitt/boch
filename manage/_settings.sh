#!/bin/sh
#
# Configurable settings for the project
#
# @todo : move some of this to yaml?
# Overrideable configuration variables
Project_name="growwild"

# Default docker image created in build, used in start/run/shell
#Docker_image="${Project_name}" # The image name which will then be used by docker
#Docker_imageversion="latest" # you can implements branching using versions, where a version is like a fork

# Docker container ID, used for start/stop/run etc
#Docker_container="`cat ${path_containterID}`"

# OS hostname used inside the container (which would impact things like avahi)
Machine_hostname="${Project_name}"

# Prefered shell configuration for the Machine
# Running as a shell is a temporary approach to getting shell access to a machine
# but should be considered secondary to other methods of running commands on the
# container.  It is a good plan for now but will be dropped in the future.
#
# @NOTE Running a shell creates a new container, and does not give access to an existing container
Machine_shell="/bin/zsh"
# arguments for docker run that should always be included: docker help run
Machine_shellrunargs="--publish-all=true --env HOME=/home/developer --user=developer"

# Machine arguments for runs.  These arguments are added to all runs (not shell runs)
Machine_runargs=""

# Build Mount list:
#
# These are run time mounts, where the host FS can be changed
# diirectly changing the container FS.
#
# @TODO get away from having to include the -v flag here, by finding a better format for this
#
# Already added: Machine_mountvolumes="${Machine_mountvolumes} --volume=${path_project}/source:/app/source"

# Mount the actual user .ssh folder in the developer user home directory.
Machine_mountvolumes="${Machine_mountvolumes} --volume=${path_userhome}/.ssh:/home/developer/.ssh-host"

