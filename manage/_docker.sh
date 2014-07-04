#
# Docker Abstraction routines
#
#
# @NOTE I tried to focus on uniformity, so there are some
#       cases where functions take parametrized arguments
#       when serial arguments could have been used.
#
# @TODO make all functions echo the docker output, so that
#       calling code can catch the docker output?
#       Maybe don't do this; build has a long pause if you do

### methods #######################################

#
# Build a new docker image from the Dockerfile
#
# -d|--dirty : leave all of the intermediate containers after the build
# -p|--path : path to the Dockerfile (default to "/conf"
# -i|--image : name to label the new image
# -q|--quiet : make the build quiet (there will be a long delay)
# -v|--version : build a specific version (defaults to latest)
#
# @TODO templating for Dockerfile, to substitute variables in ?
#   We could allow the Dockerfile to container shell vars, and pipe it
#   into the docker build process, but this would mean that 'ADD' commands
#   would need to be absolute
# @TODO templating for other files?
#
# @NOTE that templating with shell files isn't the best option,
# this should likely wait until a real toolset can be built using
# Python or Ruby.
#
docker_build() {
  local tag=""
  local clean="--rm=true"

  # default flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -d|--dirty)
        clean=""
        ;;
      -i|--image)
        image="${2}"
        shift
        ;;
      -p|--path)
        path="${2}"
        shift
        ;;
      -q|--dirty)
        clean=""
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

  # Any additional arguments  after the image are passed to the docker run
  if [ $# -gt 0 ]; then
    flags="${flags} $@"
  fi

  # build a tag from the image and version (we always explicitly build a version, but default to "latest"
  [ -n "${image}" ] && tag="--tag=${image}:${version:-latest}"

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_build: [path:${path}][image:${image}][version:${version}][tag:${tag}] ==> docker build ${clean} ${tag} ${path}"
  fi
  docker build ${clean} ${tag} ${path}
  # echo "Docker build run. '${image:-"Keyed"}' image created"
}
# Destroy any build images
#
# -i|--image docker image to be removed
# -v|--version delete only a specific version
#
# @TODO should I name this docker_rmi to be more docker oriented?
docker_rmi()
{

  # default flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
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

  # build a proper image tag
  [ -n "${version}" ] && tag="${image}:${version}" || tag="${image}"

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_rmi [image(with version):${image}][version:${version}] ==> docker rmi $tag"
  fi
  docker rmi $tag
}

#
# Start a built box
#
# Optionall use either a sheel or a command
# -c|--command "${command}" : run the provided command, instead of the default command.  NOTICE --shell, whci
# -s|--shell "${command:-"/bin/bash"}" : run the provided command, instead of the default command.  Defaults to /bin/bash
# Other Arguments
# -h|--hostname ${hostname} : define the hostname to be used
# -n|--hostname ${name} : define the container name
# -P|--allports ${name} : publish all opened ports for the container
# -t|--temporary : make the image temporary, so that it doesnt exists after it is shut down
# -u|--user : specify a container user to run the command
#
# $@ additional args for docker run
#
# @NOTE hooks are only run for background containers
#
# @TODO prevent both --shell and --command
# @TODO check for built image
# @TODO add flag for check if the image already has a running container (-s|--single)
# @TODO check execution success before running hook
docker_run()
{
  # default command: empty runs the build CMD command
  local command=""

  # if daemon then this, otherwise replace this (--shell replaces this with a shell command)
  local daemon="--detach=true"

  # default image and version, can be overriden with flags
  image=${Docker_image}
  version=${Docker_imageversion}

  # default flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--command)
        command="${2}"
        shift
        ;;
      -h|--hostname)
        flags="${flags} --hostname=$2"
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
      -n|--name)
        flags="${flags} --name=$2"
        shift
        ;;
      -s|--savehook)
        hook="${2}"
        shift
        ;;
      -P|--allports)
        flags="${flags} --publish-all=true"
        ;;
      -s|--shell)
        daemon=""
        flags="${flags} --tty=true --interactive=true"
        if [ "${2:0:1}" == "-" ]; then
          command="/bin/bash"
        else
          command="${2}"
          shift
        fi
        ;;
      -t|--temporary)
        flags="${flags} --rm"
        daemon=""
        ;;
      -u|--username) flags="${flags} --username=$2" && shift;;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Any additional arguments  after the image are passed to the docker run
  if [ $# -gt 0 ]; then
    flags="${flags} $@"
  fi

  # Run docker command
  if [ "${daemon}" == "" ]; then
    if [ "$debug" == "1" ]; then
      echo "DOCKER ABSTRACTION : docker_run (no-fork)[image:${image}][version:${version}][flags:${flags}][command:${command}] ==> docker run ${daemon} ${flags} ${image}:${version}  ${command}"
    fi

    # run the docker command in the foreground (no hooks are run in this case)
    docker run ${flags} ${image}:${version} ${command}
  else

    if [ "$debug" == "1" ]; then
      echo "DOCKER ABSTRACTION : docker_run (fork)[image:${image}][version:${version}][flags:${flags}][command:${command}] ==> docker run ${daemon} ${flags} ${image}:${version}  ${command}"
    fi

    # run the docker command and capture the container ID
    container="`docker run ${daemon} ${flags} ${image}:${version} ${command}`"

    if [ "$debug" == "1" ]; then
      echo "DOCKER ABSTRACTION: container started [ID:$container]"
    fi

    if [ -n ${hook} ]; then
      if [ "$debug" == "1" ]; then
        echo "DOCKER HOOK : Handing off to RUN hook after succesful docker run : ${hook} --image ${image} --version ${version} --name ${name} --container ${container}"
      fi
      eval "${hook} --image ${image} --version ${version} --container ${container}"
    fi
  fi
}

#
# Attach to a running container`
#
# -n|--noinput : don't attach stdin to the operation
# -c|--container : container ID or name
#
# @TODO parameter validation
# @TODO test if the container exists and is running
docker_attach()
{
  # start with an empty argument list
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
        shift
        ;;
      -n|--noinput)
        flags="${flags} --no-stdin=true"
        ;;
      -p|--sigproxy)
        flags="${flags} --sig-proxy=true"
        ;;
      -*) echo >&2 "docker_attach(): unknown flag $1 : attach [-n|--noinput] [-p|--sigproxy] -c|--container {container}";;
      *)
          break;; # terminate while loop
    esac
    shift
  done


  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_attach [container:${container}][flags:${flags}] ==> docker attach ${flags} ${container}"
  fi
  docker attach ${flags} ${container}
}

#
# Start a stopped box
#
# -c|--container : container ID or name
# $@ : additional arguments to pass to docker start
#
# @TODO validate parameters
# @TODO test if the container exists and is not running
docker_start()
{
  # start with an empty argument list
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
        shift
        ;;
      -*) echo >&2 "docker_stop(): unknown flag $1 : stop -c|--container {container}";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Any additional arguments  after the image are passed to the docker start
  if [ $# -gt 0 ]; then
    flags="${flags} $@"
  fi

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_start [container:${container}][flags:${flags}] ==> docker start ${flags} ${container}"
  fi
  docker start ${flags} ${container}
}

#
# Stop a running box
#
# -c|--container : container ID or name
# $@ : additional arguments to pass to docker kill
#
# @TODO validate parameters
# @TODO test if the container exists and is running
docker_stop()
{
  # start with an empty argument list
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
        shift
        ;;
      -*) echo >&2 "docker_stop(): unknown flag $1 : stop -c|--container {container}";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Any additional arguments  after the image are passed to the docker run
  if [ $# -gt 0 ]; then
    flags="${flags} $@"
  fi

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_stop [container:${container}][flags:${flags}] ==> docker stop ${flags} ${container}"
  fi
  docker stop ${flags} ${container}
}

#
# Delete any container
#
# -c|--container : container to remove
#
# @NOTE you can use the --rm flag in docker run to make a container temporary.
#
# @TODO validate parameters
# @TODO check if container exists
# @TODO stop container if running ?
# @TODO check execution success before running hook
docker_rm()
{

  # hook to call after removing
  hook=""

  # start with an empty argument list
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
        shift
        ;;
      -r|--removehook)
        container="${2}"
        shift
        ;;
      -*) echo >&2 "docker_rm(): unknown flag $1 : rm -c|--container {container}";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Any additional arguments  after the image are passed to the docker run
  if [ $# -gt 0 ]; then
    flags="${flags} $@"
  fi

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_rm [container:${container}][flags:${flags}] ==> docker rm ${flags} ${container}"
  fi
  docker rm ${flags} ${container}

  if [ -n ${hook} ]; then
    if [ "$debug" == "1" ]; then
      echo "DOCKER HOOK : Handing off to RUN hook after docker rm : ${hook} --image ${image} --version ${version} --name ${name} --container ${container}"
    fi
    eval "${hook} --container ${container}"
  fi
}

#
# Commit an existing container to an image:version
#
# $1 : image to be saved
# $2 : image version to be saved
# $3 : container to be saved
#
# @TODO parameter validation
# @TODO check for built image
# @TODO check for existing container
docker_commit()
{
  # default flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
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

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_commit [image:${image}][version:${version}][container:${container}][flags:${flags}] ==> docker commit ${container} ${image}:${version}"
  fi
  docker commit ${flags} ${container} ${image}:${version}
}

#
# Get the inspect JSON for the container
#
# @NOTE that JSON is not very usefull, but if it was
# then you could get all of the info that you want
# about your container from this:
# - base image
# - IP
# - forarded ports (already can get this from ps
#
# $1 : docker container
#
docker_inspect()
{
  # default flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
        shift
        ;;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_inspect [container:${container}][flags:${flags}] ==> docker inspect ${flags} ${container}"
  fi
  docker inspect ${flags} ${container}
}

#
# List running processes in a container
#
# -c|--container : which container to list
#
docker_top()
{
  # default flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
        shift
        ;;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_top [container:${container}][flags:${flags}] ==> docker top ${flags} ${container}"
  fi
  docker top ${flags} ${container}
}

#
# Show the log/console output for a container
#
# -c|--container : which container to list
#
docker_logs()
{
  # default flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="${2}"
        shift
        ;;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_logs [container:${container}][flags:${flags}] ==> docker logs ${flags} ${container}"
  fi
  docker logs ${flags} ${container}
}

#
# Check if an image exists,
#
# -i|--id : return only image IDs
#
inspect_docker_image_list()
{
  # Image name
  image=""

  # start with an empty argument list
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -i|--image)
        image="${2}"
        shift
        ;;
      -q|--idonly)  flags="$flags --quiet";;
      -*) echo >&2 "docker_image_list(): unknown flag $1 : _docker_image_list [-i|--id]";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Run docker command
  #debug "DOCKER ABSTRACTION : _docker_image_list [flags:${flags}][filter:${filter}] ==> docker images ${flags} ${filter}"
  if [ -n $image ]; then
    echo "`docker images ${flags} ${filter} | grep -i $image`"
  else
    echo "`docker images ${flags} ${filter}`"
  fi
}

#
# Check if a container exists - and if it is running
#
# -r|--running : only check for running containers
# -q|--id : return only the container ID
# $1 : container ID or name or command running (any might work)
#
# @TODO allow retrieval of just specific fields from docker_ps
inspect_docker_container_list()
{
  # assume we want to check even for containers that are not running
  local all="--all"
  # start with an empty argument list
  local flags=""
  # remove the header row, or grep for the particular container/command
  local filter=""
  # container
  container=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        container="$2"
        shift
        ;;
      -q|--idonly)  flags="$flags --quiet";;
      -r|--running)  all="";;
      -*) echo >&2 "docker_container_list(): unknown flag $1 : exists [-r|--running] -c|--container {container} ]";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Run docker command
  if [ -n $container ]; then
    # I debated about the -i, but it seems to be better than case collisions
    echo "`docker ps ${flags} ${all} ${filter} | grep -i $container`"
  else
    echo "`docker ps ${flags} ${all} ${filter}`"
  fi
}

# check if docker container $1 exists (has ever been started)
_docker_container_exists()
{
  local container=$1
  local exists="`inspect_docker_container_list --idonly --container $container`"
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION: _docker_container_exists [container:$container] ==> inspect_docker_container_list --idonly --container $container ==> ${exists}"
  fi

  if [ -n "$exists" ]; then
    return 0
  else
    return 1
  fi
}
# check if docker container $1 is running
_docker_container_isrunning()
{
  local container=$1
  local running="`inspect_docker_container_list --idonly --running --container $container`"
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION: _docker_container_isrunning [container:$container] ==> inspect_docker_container_list --idonly --running --container $container ==> ${running}"
  fi

  if [ -n "$running" ]; then
    return 0
  else
    return 1
  fi
}
