#!/bin/sh
#
# some centralized processing, and environment determination
# then inclusion of common tools
#

for i in "$@";do
    params="$params \"${i//\"/\\\"}\""
done;

# get some paths
path_execution=`pwd`
path_conf="$path_project/conf"
path_manage="$path_project/manage"

# include docker settings and utilities
source ${path_manage}/_settings.sh
source ${path_manage}/_docker.sh

Docker_containerID="$(cat "$path_manage/_container")"
