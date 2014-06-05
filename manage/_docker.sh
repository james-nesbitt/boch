
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

  if [ "$debug" == "1" ]; then
    echo "docker_build: [path:${path}][image:${image}][version:${version}][tag:${tag}]"
    echo "docker_build: RUN : docker build ${tag} ${path}"
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

  docker rmi $image
}
#
# Start a built box
#
# -h|--hostname ${hostname} : define the hostname to be used
# -c|--command "${command:-"/bin/bash"}" : run the provided command, instead of the default command.  Defaults to /bin/bash
# -t|--temporary : make the image temporary, so that it doesnt exists after it is shut down
#
# $1 image
# $@ additional args for docker run
#
# @TODO : check for built image
# @TODO : add flag for check if the image already has a running container (-s|--single)
docker_run()
{
  # default command: empty runs the build CMD command
  command=""
  # default flags
  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--command)
        if [ "${2:0:1}" == "-" ]; then
          command="/bin/bash"
        else
          command="${2}"
          shift
        fi
        shift
        ;;
      -h|--hostname)
        flags="${flags} --hostname $2"
        shift
        ;;
      -t|--temporary)
        flags="{$flags} --rm"
        shift
        ;;
      -*) echo >&2 "docker_run: unknown flag $1 : run [-h|--hostname] [images] [additional flags]";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # get the image name as the first argument after the flags
  $image="${1}"
  shift

  # Any additional arguments  after the image are passed to the docker run
  if [ -n $@ ]; then
    flags="${flags} ${@}"
  fi

  Docker_containerID="$(docker run -d ${flags} ${Docker_image})"
  echo "${Docker_containerID}" > ${path_containterID}
  echo "MANAGE=> Started ${Docker_image} as container:${Docker_container} ID:${Docker_containerID} [container ID saved in ${path_containterID}]"
}
#
# start a shell version of a container
#
# @todo : merge with docker_run as a flag
docker_command()
{
  docker run --hostname=${Machine_hostname} --name=${Docker_container} --user="developer" --env HOME=/home/developer -t -i -P ${Docker_rm} ${Machine_volumes} ${Docker_image} ${1:-"/bin/zsh"}
}

#
# Attach to a running container
#
# @TODO test if the container exists and is running
docker_attach()
{
  docker attach ${Docker_container}
}

#
# Stop a running box
#
# @TODO test if the container exists and is running

docker_stop()
{
  docker kill $Docker_containerID
}

#
# Delete any
docker_rm()
{
  docker rm $Docker_container
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

  docker inspect $container
}

#
# Check if an image exists,
#
docker_image_list()
{

  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -i|--id)  flags="${flags} --quiet";;
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

  echo "`docker images ${flags} ${filter}`"
}

#
# Check if a container exists - and if it is running
#
# -r}--running : only check for running containers
# $1 : container ID or name (both will work)
#
# @TODO allow retrieval of just specific fields from docker_ps
_docker_container_list()
{
  # assume we want to check even for containers that are not running
  all="--all"

  $flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -r|--running)  all="";;
      -*) echo >&2 "docker_container_list(): unknown flag $1 : exists [-r|--running] [container]";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  container=$1

  filter=" | sed -e \"1d\" "
  if [ -n $container ]; then
    filter="${filter} | grep -i ${container}"
  fi
  echo "`docker ps ${flags} ${all} ${filter}`"

}
