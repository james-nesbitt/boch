#!/bin/bash

#include tools
path_tools="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${path_tools}/_sites.sh"
processed=0

source=$1
destination=$2
tag=${3:-current}

if [ "$destination" == "prod" ]; then
  read -r -p "This will destroy the @prod DBs, and replace them with dumped data. Are you sure? [y/N] " response
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
  label="${name#${source}\.}"
  alias="@${destination}.${label}"
  file="${DIR_DUMP}/${source}.${label}.${tag}.sql"

  if [[ -f $file ]]; then
    echo  "$processed:drush_restore[$file-->$alias] RESTORED FROM FILE $(drush $alias sql-query --file=$file)"
  else
    echo  "$processed:drush_restore[$file-->$alias] RESTORE FAILED, FILE NOT FOUND"
  fi
done
