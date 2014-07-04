#!bin/sh
#
# COMMAND: Output container process logs
#

# command help function
log_help()
{
  echo "
Output the container process logs
  -c|--container {container} : override the default container name with an ID or name of a running container

@TODO check for existing and running container
"
}

# command execute function
log_execute()
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

  # Run the logs function
  debug "COMMAND: logs [ handing off to docker abstraction ] ==> docker_logs --container ${container}"
  docker_logs --container "${container}"
}
