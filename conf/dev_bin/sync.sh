#!/bin/bash

#include tools
path_tools="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${path_tools}/_sites.sh"
processed=0

source=$1
destination=$2

if [ "$2" == "prod" ]; then
  read -r -p "This will destroy the @prod DBs, and replace them with $1 data. Are you sure? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    echo "Operation confirmed -- but still cancelling anyway because this has never really been tested"
    exit
  else
    echo "Operation cancelled"
    exit
  fi

fi

for name in $( sitelist $source ); do
  ((processed++))
  alias="@$name"
  label="${name#${source}\.}"
  aliases="@${source}.$label @${destination}.$label"

  echo  "$processed:drush_sync[$label/$aliases] SYNCED $(drush sql-sync $aliases -y --no-cache /dev/null 2>&1)"
done
