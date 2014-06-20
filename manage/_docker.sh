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
# -p|--path : path to the Dockerfile (default to "/conf"
# -i|--image : name to label the new image
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
  tag=""

  # default flags
  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -i|--image)
        image="${2}"
        shift
        ;;
      -p|--path)
        path="${2}"
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

  # Any additional arguments  after the image are passed to the docker run
  if [ $# -gt 0 ]; then
    flags="${flags} $@"
  fi

  # build a tag from the image and version (we always explicitly build a version, but default to "latest"
  [ -n "${image}" ] && tag="--tag=${image}:${version:-latest}"

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_build: [path:${path}][image:${image}][version:${version}][tag:${tag}] ==> docker build ${tag} ${path}"
  fi
  docker build ${tag} ${path}
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
  flags=""
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

  tag="${image}"
  [ -n "${version}" ] && tag="${tag}:${version}"

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
# @TODO prevent both --shell and --command
# @TODO check for built image
# @TODO add flag for check if the image already has a running container (-s|--single)
docker_run()
{
  # default command: empty runs the build CMD command
  command=""

  # if daemon then this, otherwise replace this (--shell replaces this with a shell command)
  daemon="--detach=true"

  # default image and version, can be overriden with flags
  image=${Docker_image}
  version=${Docker_imageversion}

  # default flags
  flags=""
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
    docker run ${daemon} ${flags} ${image}:${version} ${command}
  else

    if [ "$debug" == "1" ]; then
      echo "DOCKER ABSTRACTION : docker_run (fork)[image:${image}][version:${version}][flags:${flags}][command:${command}] ==> docker run ${daemon} ${flags} ${image}:${version}  ${command}"
    fi

    container="`docker run ${daemon} ${flags} ${image}:${version} ${command}`"

    if [ -n ${hook} ]; then
      if [ "$debug" == "1" ]; then
        echo "DOCKER HOOK : Handing off to RUN hook after succesful docker run : ${hook} --image ${image} --version ${version} --container ${container}"
      fi
      eval "${hook} --image ${image} --version ${version} -ontainer ${container}"
    else
      echo "CONTROL: container started [ID:$container]"
    fi
  fi
}

#
# Attach to a running container
#
# -n|--noinput : don't attach stdin to the operation
# -c|--container : container ID or name
#
# @TODO parameter validation
# @TODO test if the container exists and is running
docker_attach()
{
  # start with an empty argument list
  flags=""
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
  flags=""
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
    echo "DOCKER ABSTRACTION : docker_start [container:${container}][flags:${flags}] ==> docker start ${$flags} ${container}"
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
  flags=""
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
docker_rm()
{
  # start with an empty argument list
  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
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
    echo "DOCKER ABSTRACTION : docker_rm [container:${container}][flags:${flags}] ==> docker rm ${$flags} ${container}"
  fi
  docker rm ${flags} ${container}
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
  flags=""
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
  flags=""
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
# Check if an image exists,
#
# -i|--id : return only image IDs
#
_docker_image_list()
{
  # start with an empty argument list
  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -i|--id)
        flags="${flags} --quiet"
        ;;
      -*) echo >&2 "docker_image_list(): unknown flag $1 : _docker_image_list [-i|--id]";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  image=$1

  filter=" | sed -e \"1d\" "
  if [ -n $image ]; then
    filter="${filter} | grep -i ${image}"
  fi

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : _docker_image_list [flags:${flags}][filter:${filter}] ==> docker images ${flags} ${filter}"
  fi
  echo "`docker images ${flags} ${filter}`"
}

#
# Check if a container exists - and if it is running
#
# -r|--running : only check for running containers
# -q|--id : return only the container ID
# $1 : container ID or name or command running (any might work)
#
# @TODO allow retrieval of just specific fields from docker_ps
_docker_container_list()
{
  # assume we want to check even for containers that are not running
  all="--all"
  # start with an empty argument list
  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -q|--idonly)  flags="$flags --quiet";;
      -r|--running)  all="";;
      -*) echo >&2 "docker_container_list(): unknown flag $1 : exists [-r|--running] [container]";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  container=$1

  # remove the header row, or grep for the particular container/command
  filter=" | sed -e \"1d\" "
  if [ "${container}" -ne "" ]; then
    filter="${filter} | grep -i ${container}"
  fi

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : _docker_container_list [flags:${flags}][all:${all}][filter:${filter}] ==> docker ps ${flags} ${all} ${filter}"
  fi
  docker ps ${flags} ${all} ${filter}

}

