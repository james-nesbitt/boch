
#
# Build a new docker image from the Dockerfile
#
# $1 : path to the Dockerfile (default to "/conf"
# $2 : name to label the new image
# $3 : build a specific version (defaults to latest)
#
# @TODO templating for Dockerfile, to substitute variables in ?
#   We could allow the Dockerfile to container shell vars, and pipe it
#   into the docker build process, but this would mean that 'ADD' commands
#   would need to be absolute
# @TODO templating for other files?
docker_build() {
  tag=""

  path="${1:-${path_conf}}"
  image="${2}"
  version="${3:-"latest"}"
  [ -n "${image}" ] && tag="--tag=${image}:${version}"

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_build: [path:${path}][image:${image}][version:${version}][tag:${tag}] ==> docker build ${tag} ${path}"
  fi
  docker build ${tag} ${path}
  echo "Docker build run. '${image:-"Keyed"}' image created"
}
# Destroy any build images
#
# $1 docker image to be removed
# $2 delete only a specific version
#
docker_destroy()
{
  image=${1:-${Docker_image}}
  [ -z "${2}" ] && image="${image}:${2}"

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_destroy [image(with version):${image}][version:${2}] ==> docker rmi $image"
  fi
  docker rmi $image
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
  daemon="-d"

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
      -P|--allports)
        flags="${flags} --publish-all=true"
        ;;
      -s|--shell)
        daemon="--tty=true --interactive=true"
        if [ "${2:0:1}" == "-" ]; then
          command="/bin/bash"
        else
          command="${2}"
          shift
        fi
        ;;
      -t|--temporary) flags="${flags} --rm";;
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
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_run [image:${image}][version:${version}][flags:${flags}][command:${command}] ==> docker run ${daemon} ${flags} ${image}:${version}"
  fi
#  echo "`docker run ${daemon} ${flags} ${image}:${version}`"
}

#
# Attach to a running container
#
# -n|--noinput : don't attach stdin to the operation
# $1 container
#
# @TODO test if the container exists and is running
docker_attach()
{
  # start with an empty argument list
  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -n|--noinput)
        flags="${flags} --no-stdin"
        ;;
      -*) echo >&2 "docker_attach(): unknown flag $1 : attach [-n|--noinput] [container]";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  container="${1}"
  shift

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_attach [container:${container}][flags:${flags}] ==> docker attach ${flags} ${container}"
  fi
  docker attach ${flags} ${container}
}

#
# Stop a running box
#
# $1 : container ID
# $@ : additional arguments to pass to docker kill
#
# @TODO test if the container exists and is running

docker_stop()
{
  container="${1}"
  shift

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_stop [container:${container}][additional arguments:${@}] ==> docker stop $@ ${container}"
  fi
  docker stop $@ ${container}
}

#
# Delete any container
docker_rm()
{
  container=$1

  docker rm $container
}


#
# Commit an existing container to an image:version
#
# $1 : image to be saved
# $2 : image version to be saved
# $3 : container to be saved
#
# @TODO check for built image
# @TODO check for existing container
docker_commit()
{

  # default image and version, can be overriden with flags
  image=$1
  version=$2
  container=$3

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : docker_commit [image:${image}][version:${version}][container:${container}] ==> docker commit ${container} ${image}:${version}"
  fi
  echo "`docker commit ${container} ${image}:${version}`"
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
  $container=$1

  # Run docker command
  docker inspect $container
}

#
# Check if an image exists,
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
      -*) echo >&2 "docker_image_list(): unknown flag $1 : exists [-r|--running] [container]";;
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
  $flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -q|--id)  flags="$flags --quiet";;
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
  if [ -n $container ]; then
    filter="${filter} | grep -i ${container}"
  fi

  # Run docker command
  if [ "$debug" == "1" ]; then
    echo "DOCKER ABSTRACTION : _docker_container_list [flags:${flags}][all:${all}][filter:${filter}] ==> docker ps ${flags} ${all} ${filter}"
  fi
  echo "`docker ps ${flags} ${all} ${filter}`"

}
