#!/bin/sh
#
# Command based docker container management
#

############################
# Process config Arguments #
############################
# -v|--verbose {level} : output debugging info
# -l|--log {level} : enable debug logging
# -f|--force : ignore critical errors (don't halt)
#
# @TODO find a way past the described silliness

while [ $# -gt 0 ]
do
  case "$1" in
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
  echo "
COMMAND: final control settings: [
  >COMMAND TO BE EXECUTED
  -->Command:${COMMAND}
  -->Command Args:${@}
]"
fi

###################################################################
# Process command : pass the rest of the arguments to the command #
###################################################################

# execute any existing pre hooks
debug --level 7 --topic "COMMAND" "Running global:pre hooks => hooks_execute global --state \"pre\" --command \"${COMMAND}\""
hooks_execute command --state "pre" --command "${COMMAND} $@"

# execute any existing pre hooks
debug --level 7 --topic "COMMAND" "Running global:hooks => hooks_execute global --command \"${COMMAND}\""
hooks_execute command --command "${COMMAND} $@"

# execute any existing pre hooks
debug --level 7 --topic "COMMAND" "Running global:post hooks => hooks_execute global --state \"post\" --command \"${COMMAND}\""
hooks_execute command --state "post" --command "${COMMAND} $@"

# We have a command file, so we hand the execution off to
# that script to run inline (not as a function)
if _include_command ${COMMAND}; then

  # execute any existing pre hooks
  debug --level 7 --topic "COMMAND" "Running global:pre hooks => hooks_execute global --state \"pre\" --command \"${COMMAND}\""
  hooks_execute command --state "pre" --command "${COMMAND} $@"

  command_function="${COMMAND}_execute"
  debug --level 4 --topic "COMMAND" "command [ ${COMMAND} ] handing off to command script : ${command_function}"
  eval ${command_function} $@
  success=$?
  if [ $success == 0 ]; then
    echo "$result"
    debug --level 6 --topic "COMMAND" "${COMMAND} succeeded."

    # execute any existing post hooks
    debug --level 7 --topic "COMMAND" "Running global:post hooks => hooks_execute global --state \"post\" --command \"${COMMAND}\""
    hooks_execute command --state "post" --command "${COMMAND} $@"
  else
    debug --level 2 --topic "COMMAND" "Command execution failed for command ${COMMAND}."

    # execute any existing post hooks
    debug --level 7 --topic "COMMAND" "Running global:post hooks => hooks_execute global --state \"fail\" --command \"${COMMAND}\""
    hooks_execute command --state "fail" --command "${COMMAND} $@"
  fi
  exit $sucess

else
  # no command was found
  debug --level 4 --topic "COMMAND" "${COMMAND} failed.  Unkown command."
  echo "CONTROL: Unknown command \"${COMMAND}' - try using 'control help' for instructions."
fi
