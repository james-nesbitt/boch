#!/bin/sh
#
# Command based docker container management
#

############################
# Process config Arguments #
############################
# -h|--help : get help instead of running the command
# -v|--verbose {level} : output debugging info
# -l|--log {level} : enable debug logging
# -f|--force : ignore critical errors (don't halt)
#
# @TODO find a way past the described silliness

# turn this to >0 if you want to get help instead of running a command
help=0

while [ $# -gt 0 ]
do
  case "$1" in
    -h|--help)
      help=1
      ;;
    -v|--verbose)
      vflag=on
      # if an integer level was passed, take it, otherwise default to 5
      if [ -n "$2" ] && [ -z "${2##[0-9]}" ]; then
        debug=${2}
        shift
      else
        debug=5
      fi
      ;;
    -l|--log)
      # if an integer level was passed, take it, otherwise default to 8
      if [ -n "$2" ] && [ -z "${2##[0-9]}" ]; then
        log=${2}
        shift
      else
        log=8
      fi
      ;;
    -f|--force)
      # lower the critical error level so that errors don't halt
      _debug_critical_level=0
      ;;
    -*)
        echo >&2 "usage: $0 [-v|--verbose] [-l|--log [{log level}]]  [command ...].  Try \"help\" for more instructions."
        exit 1;;
    *)
        break;; # terminate while loop
  esac
  shift
done

#####################################################
# Find out where we are, and connect to the _config #
#####################################################

# path to the root of this project
path_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
# include _config, which will do the rest of the work.
source "${path_script}/_config"

################################################
# Determine what command is supposed to be run #
################################################
# the first non-hyphenated argument is the command
COMMAND=$1
shift


  # Maybe print some debug info (debug command loses carriage returns, so we echo ourselves)
if [ $debug -gt 3 ]; then
  if [ $help -gt 0 ]; then
    echo "
COMMAND: final control settings: [
  >HELP MODE ENABLED
  >COMMAND TO BE HELPED WITH
  -->Command:${COMMAND}
  -->Command Args:${@}
]"
  else
    echo "
COMMAND: final control settings: [
  >COMMAND TO BE EXECUTED
  -->Command:${COMMAND}
  -->Command Args:${@}
]"
  fi
fi

###################################################################
# Process command : pass the rest of the arguments to the command #
###################################################################

if [ $help -gt 0 ]; then

  # execute any existing pre hooks
  debug --level 7 --topic "COMMAND" "Running global:hooks => hooks_execute command --state \"help\" \"${COMMAND}\""
  hooks_execute command --state "help" "${COMMAND} $@"
  success=$?

else

  # execute any existing pre hooks
  debug --level 7 --topic "COMMAND" "Running global:pre hooks => hooks_execute command --state \"pre\" \"${COMMAND}\""
  hooks_execute command --state "pre" "${COMMAND} $@"

  # execute any existing pre hooks
  debug --level 7 --topic "COMMAND" "Running global:hooks => hooks_execute command \"${COMMAND}\""
  hooks_execute command "${COMMAND} $@"
  success=$?

  if [ $success == 0 ]; then
    # execute any existing post hooks
    debug --level 7 --topic "COMMAND" "Running global:post hooks => hooks_execute command --state \"post\" \"${COMMAND}\""
    hooks_execute command --state "post" "${COMMAND} $@"
  fi

fi