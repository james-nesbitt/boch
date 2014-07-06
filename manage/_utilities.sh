#!bin/sh
#
# Utility functions
#

# Handle debug messages
#
# -t|--topic {topic} : string grouping topic
# -l|--level [{level}] : optional specific verbosity level 1-10
#       verbosity level (off the top of my head):
#        1 : critical
#        2 : Serious error in abstraction
#        3 : error
#        4 : Important implementation notification
#        5 : Standard implementation information
#        6 : Extra implementation information, like success messages
#        7 : superfluous info (running hooks)
#        8 : 
#        9 : tiny detail, output may actually break the implementation
# 
debug()
{

  # default organization config
  local level=5
  local topic="GENERAL"

  while [ $# -gt 0 ]
  do
    case "$1" in
      -l|--level)
        level=${2}
        shift
        ;;
      -t|--topic)
        topic="${2}:"
        shift
        ;;
      *)
        break;
    esac
    shift
  done

  if [ ${level} -le ${debug} ]; then
    echo "[${level}]${topic} $@"
  fi
  if [ ${level} -le ${log} ]; then
    echo "${executionid} ${date} : [${level}]${topic} $@" >> ${path_log}
  fi
}

# Run hooks for a command
#
# Conceptually, the function arguments determine
# a path, and all function in that path are executed
#
# $1 : command
# -s|--state {state} : state e.g. pre or post
# $@ : passed to the hook functions
#
# @NOTE this will be the center of a hook system,
#   but is currently not used (not tested or maintained)
hooks_execute()
{
  # require the first argument to be the command
  command=$1
  shift

  # base hooks path
  path="${path_hooks}/${command}"

  while [ $# -gt 0 ]
  do
    case "$1" in
      -s|--state)
        path="${path}/${2}"
        shift
        ;;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  debug --level 8 --topic "UTILITY" "hooks_execute [command:${commande}][state:${state}] ==> executing any hooks in ${path}"
  if [ -e ${path} ]; then
  	for hook in ${path}/*; do
	    debug --level 8 --topic "UTILITY" "HOOK: Executing Hook: ${hook} $@"
  	  source ${hook} $@
  	done
  fi
}
