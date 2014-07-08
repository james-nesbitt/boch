#!bin/sh
#
# COMMAND: pause and un-pause a running container
#

# Command help function
pause_help()
{
  echo "
Pause or un-Pause all running processes inside a container.

Docker allows the pausing of all processes in a container, to prevent
any CPU-Usage by the processes, without losing their state.

  -c|--container {container} : override the container to pause

@TODO test for container is already running
@TODO text for container is paused
"
}

# Command execute function
pause_execute()
{
  # Default direction (pause versus unpause)
  local pause="pause"
  # Container default
  container=${Docker_container}

  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="$2"
        shift
        ;;
      -u|--unpause)
        pause="unpause"
        ;;
      -*)
        echo >&2 "unknown flag $1 : pause [-c|--container] {container} [-u|--unpause]"
        break;; # terminate while loop
      *)
        break;
    esac
    shift
  done

  # un-pause a paused container
  if [ "${pause}" == "unpause" ]; then
    # Run the pause function
    debug --level 5 --topic "COMMAND" "start [ handing off to docker start abstraction ] ==> docker_start --container ${container}"
    docker_unpause --container ${container}
    return $?
  
  # pause the container
  else
    # Run the pause function
    debug --level 5 --topic "COMMAND" "start [ handing off to docker start abstraction ] ==> docker_start --container ${container}"
    docker_pause --container ${container}
    return $?
  fi
}
