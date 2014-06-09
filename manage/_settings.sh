#!/bin/sh
#
# Configurable settings for the project
#
# @todo : move some of this to yaml?
# Overrideable configuration variables
#Project_name="filesafe_name_for_the_project"

# Default docker image created in build, used in start/run/shell
Docker_image="bmnr"
#Docker_imageversion="latest"

# Docker container ID, used for start/stop/run etc
#Docker_container="`cat ${path_containterID}`"

# OS hostname used inside the container (which would impact avahi)
Machine_hostname="bmnr"

# Prefered shell for the Machine
Machine_shell="/bin/zsh"
Machine_shellrunargs="--env HOME=/home/developer --user=developer"

# Build Mount list:
#
# These are run time mounts, where the host FS can be changed
# diirectly changing the container FS.
#
# @TODO get away from having to include the -v flag here
#
# Copy this row if you want to add more mappings
# Already added: Machine_mountvolumes="${Machine_mountvolumes} --volume=${path_project}/source:/app/source"
