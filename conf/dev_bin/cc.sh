#!/bin/bash
#include tools
path_tools="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${path_tools}/_sites.sh"
processed=0

# give a drush status for each site
eachsite_drush $1 "cc all"
