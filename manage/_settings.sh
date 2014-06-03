#!/bin/sh
#
# Configurable settings for the project
#
# @todo : move some of this to yaml?

# Overrideable configuration variables
#Project_name="filesafe_name_for_the_project"

# Docker image created in build, used in start/run/shell
#Docker_image="docker image"

# Docker container ID, used for start/stop/run etc
#Docker_container="`cat ${path_containterID}`"

# OS hostname used inside the container (which would impact avahi)
#Machine_hostname="project"

# Comment this out to make shell.sh shells last.
Docker_rm="--rm"

# Build Mount list:
#
# These are run time mounts, where the host FS can be changed
# diirectly changing the container FS.  The first line sets
# the variable, and the rest add to it.
Machine_volumes=""
Machine_volumes="${Machine_volumes} -v ${path_project}/source:/app/source"
Machine_volumes="${Machine_volumes} -v ${path_project}:/app/project"
