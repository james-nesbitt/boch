#!bin/sh
#
# COMMAND: Stop any running containers
#

# Command help function
stop_help()
{
  echo "
Stop the container if it is running

  -c|--container {container} : override the default container name with an ID or name of a running container

@TODO check for existing and running container
@TODO make a better way to empty the \"saved\" container file
"
}

# command execute function
stop_execute()
{
  container=${Docker_container}

  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
        shift
        ;;
      -*)
        echo >&2 "unknown flag $1 : stop [-c|--container] {container}"
        exit
        ;;
      *)
        break;
    esac
    shift
  done

  # Run the stop function
  debug "COMMAND: stop [ handing off to docker abstraction ] ==> docker_stop --container ${container}"
  docker_stop --container "${container}"

  # empty the saved container (THIS NEEDS ABSTRACTION)
  _containerID_save --container
}
