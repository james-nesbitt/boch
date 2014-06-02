#!/bin/sh
#
# Configurable settings for the project
#
# @todo : move this to yaml?

Docker_image="{project}"
Docker_container="${Docker_image}_dev"

Docker_rm="--rm"

Machine_hostname="$Docker_container"

# Build Mount list - all of
Machine_volumes=""
Machine_volumes="${Machine_volumes} -v ${path_project}/source:/app/source"
Machine_volumes="${Machine_volumes} -v ${path_project}:/app/project"

# this isn't really a setting, but it is used functionally, and maybe should be overridable
# @todo : move to _main.sh, and then allow an override here?
