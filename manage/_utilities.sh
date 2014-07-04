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

  if [ "$debug" == "1" ]; then
    echo "UTILITY: hooks_execute [command:${commande}][state:${state}] ==> executing all hosts in ${path}"
  fi
  if [ -e ${path} ]; then
  	for hook in ${path}/*; do

	  if [ "$debug" == "1" ]; then
	    echo " --> Executing Hook: ${hook} $@"
	  fi  		
  	  eval ${hook} $@
  	done
  fi

}

# A local callback for saving container IDs
# @NOTE This is a pretty limited tool, but is
# the only iteration that we need until a better
# ID management system is designed
#
# -c|--container {container} : ID of new container
# -i|--image {image} : docker image used
# -n|--name {name} : container name if assigned
# -v|--version {version} : docker image version used
#
# @TODO Parameter validation
#
_container_save()
{
  # default flags
  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
        shift
        ;;
      -n|--name)
        name="${2}"
        shift
        ;;
      -i|--image)
        image="${2}"
        shift
        ;;
      -v|--version)
        version="${2}"
        shift
        ;;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Write the container ID to the container file
  debug "CONTROL HOOK : _container_save [image:${image}][version:${version}][container:${container}][name:${name}] ==> echo ${name:-container} > ${path_containterID}"
  echo ${name:-container} > ${path_containter}
}
# remove any reference to an active container
_container_empty()
{
  debug "CONTROL HOOK : _container_empty ==> echo ${name:-container} > ${path_containterID}"
  echo ${name:-container} > ${path_containter}
}
