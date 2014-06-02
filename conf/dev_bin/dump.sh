#!/bin/bash

#include tools
path_tools="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${path_tools}/_sites.sh"
processed=0

source=$1
tag=${2:-current}

for name in $( sitelist $source ); do
  ((processed++))
  alias="@$name"
  label="${name#${source}\.}"
  file="${DIR_DUMP}/${source}.${label}.${tag}.sql"

  echo  "$processed:drush_dump[$alias-->$file] DUMPED TO FILE $(drush $alias sql-dump --ordered-dump > $file)"
done
