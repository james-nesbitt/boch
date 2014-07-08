#!bin/sh
#
# Utility functions
#

# Handle debug messages
#
# -t|--topic {topic} : string grouping topic
# -l|--level [{level}] : optional specific verbosity level 1-10
#       verbosity level (off the top of my head):
#        1 : critical - Execution will stop
#        2 : Serious error in abstraction
#        3 : error (will print without debug turned on)
#        4 : Important implementation notification/failure
#        5 : Standard implementation information (standard log message)
#        6 : Extra implementation information, like success messages
#        7 : superfluous info (running hooks)
#        8 : Top detail, that is safe to echo
#        9 : tiny detail, output may actually break the implementation!
# 

#set an execution threshold.  Anything -le will stop execution flow.
_debug_critical_level=${_debug_critical_level:-1}

# Make a new debug log
debug()
{

  # 0= not critical, 1= critical - execution will stop
  local critical=0

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

  if [ ${level} -le ${_debug_critical_level} ]; then
    critical=1
  fi

  if [ ${level} -le ${debug} ]; then
    echo "[${level}]${topic} $@"
    if [ ${critical} -gt 0 ]; then
      echo "STOPPING EXECUTION DUE TO CRITICAL NOTICE"
    fi
  fi
  if [ ${level} -le ${log} ]; then
    echo "${executionid} ${date} : [${level}]${topic} $@" >> ${path_log}
    if [ ${critical} -gt 0 ]; then
      echo "STOPPING EXECUTION DUE TO CRITICAL NOTICE" >> ${path_log}
    fi
  fi

  if [ ${critical} -gt 0 ]; then
    exit 1
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
	    debug --level 8 --topic "UTILITY" "HOOK: Executing Hook script (source): ${hook} $@"
  	  source ${hook} $@
  	done
  fi
}

# File and folder functions
#
# Various operations in the system require a path or file
# exist.  These two functions will create the path or
# return an error if they can't
#

# Create an empty folder, if it doesn't already exist
#
# $1 : folder path
#
_ensure_folder()
{
  # Take the path from the first argument
  local path=$1
  debug --level 9 --topic "UTILITY" " FILEFOLDER : _ensure_folder [path:$path]"

  if [ -e $path ]; then
    if [ -f $path ]; then
      debug --level 4 --topic "UTILITY" " FILEFOLDER : _ensure_folder [path:$path] ==> could not create folder ${path}.  Already exists but not as a directory."
    else
      return 0
    fi
  else
    debug --level 8 --topic "UTILITY" " FILEFOLDER : _ensure_folder [path:$path] ==> creating missing folder ${path}"
    mkdir -p $path
    local success=$?
    if [ $success -gt 0 ]; then
      debug --level 4 --topic "UTILITY" " FILEFOLDER : _ensure_folder [path:$path] ==> could not create folder ${path}"
    fi
    return $success
  fi
}

# Create an empty file, if it doesn't already exist
#
# $1 : file path
#
_ensure_file()
{
  # Take the path from the first argument
  local path=$1
  debug --level 9 --topic "UTILITY" " FILEFOLDER : _ensure_file [path:$path]"

  if [ -e $path ]; then
    if [ -d $path ]; then
      debug --level 4 --topic "UTILITY" " FILEFOLDER : _ensure_file [path:$path] ==> could not create file ${path}.  Already exists but as a directory."
    else
      return 0
    fi
  else
    debug --level 8 --topic "UTILITY" " FILEFOLDER : _ensure_file [path:$path] ==> creating missing file ${path}"
    mkdir -p $path
    local success=$?
    if [ $success -gt 0 ]; then
      debug --level 4 --topic "UTILITY" " FILEFOLDER : _ensure_file [path:$path] ==> could not create file ${path}"
    fi
    return $success
  fi
}
