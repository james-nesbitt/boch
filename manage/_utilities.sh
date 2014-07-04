#!bin/sh
#
# Utility functions
#

# Handle debug messages
#
# 
debug()
{
  if [ "$debug" == "1" ]; then
    echo $@
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

  #debug "UTILITY: hooks_execute [command:${commande}][state:${state}] ==> executing any hooks in ${path}"
  if [ -e ${path} ]; then
  	for hook in ${path}/*; do
	    #debug  "HOOK: Executing Hook: ${hook} $@"	
  	  source ${hook} $@
  	done
  fi
}
