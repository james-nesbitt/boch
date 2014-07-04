#!bin/sh
#
# COMMAND: Show status for a container
#

# Help function
status_help()
{
 echo "
Show the status for a container

This is really just a wrapper for $/> docker ps
The function returns some readable status text that the users
can use to describe the status of the container.

  -c|--container {container} : override the default container name with an ID or name of a running container

@TODO check for existing and running container
"
}

# command execute function
status_execute()
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

  # Run the ps function
  debug "COMMAND: status [ handing off to docker abstraction ] ==> docker_top --container ${container}"
  echo "EXISTS:"
  echo "CONTAINER ID        IMAGE                       COMMAND             CREATED             STATUS              PORTS                                         NAMES"
  inspect_docker_container_list --container "${container}"
}
