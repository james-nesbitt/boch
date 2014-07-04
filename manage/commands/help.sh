#!bin/sh
#
# COMMAND: Show help for, general or for a command
#

# command help function
help_help()
{
  echo "
Print help for a command

  \$1 : command for which to print help

@NOTE right now this is just printing a static help message.

@TODO make this print the help from each command if no command is passed
"
  exit
}

# command execute function
help_execute()
{

  if [ -z $1 ]; then

    echo "
  Manage Controller

  This script is the central tool used to build, start and stop project containers.

  Useage: control {global args} {command} {args}

  Global Args:
    --v|--verbose : make the execution verbose
    --h|--help : give instructions instead of executing action

  Commands:"

    for command in ${path_commands}/*; do
      command="`basename $command`"
      echo "  --> ${command:0:-3}"
    done

    echo " 
    * Command specific help is available using \"help {command}\""

  else

    debug "COMMAND: help : Print help for \"$1\" [path:${path}][function:${function}] ==>"

    path="${path_commands}/$1.sh"
    function="$1_help"
    if [ -f $path ]; then
      source $path
      eval $function
    else
      echo "Command not found, could not show help.  try again with \"help-v $1\""
    fi

  fi

}
