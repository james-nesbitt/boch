#!/bin/bash

# DIR for DB dumps
DIR_DUMP="/home/developer/dumps"

# get a list of all of the matching sites
function sitelist {
  echo "$(drush sa | grep "$1\.")"
}

# Iterate through all of the sites and call a callback
# -- really this is a looping demo --
function eachsite_drush {
  processed=0
  callback=$2
  source=$1
  for name in $( sitelist $source ); do
    ((processed++))
    alias="@$name"
    label="${name#${source}\.}"

    echo  "$processed:eachsite_drush[$alias/$label] $(drush $alias $callback)"
  done
}
