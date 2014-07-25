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
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_build: [path:${path}][image:${image}][version:${version}][tag:${tag}] ==> docker build ${clean} ${tag} ${path}"
  docker build ${clean} ${tag} ${path}
  local success=$?
  if [ $success == 0 ]; then
    debug --level 6 --topic "DOCKER ABSTRACTION" "Docker build run. '${image:-"Keyed"}' image created"
  else
    debug --level 2 --topic "DOCKER ABSTRACTION" "Docker build failed."
  fi
  return $success
}
# Destroy any build images
#
# -i|--image docker image to be removed
# -v|--version delete only a specific version
#
# -f|--force : delete an image, even if it is being used
#
# @NOTE delete an image with running containers does not stop the
#   containers, it doesn't actuall delete the image, but rather
#   it removes the label, and leaves the image.
#
# @TODO should I name this docker_rmi to be more docker oriented?
docker_rmi()
{

  # default flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -f|--force)
        flags="${flags} --force"
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

  # build a proper image tag
  [ -n "${version}" ] && tag="${image}:${version}" || tag="${image}"

  # Run docker command
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_rmi [image(with version):${image}][version:${version}][flags:${flags}] ==> docker rmi ${flags} ${tag}"
  docker rmi ${flags} ${tag}
  local success=$?
  if [ $success == 0 ]; then
    debug --level 6 --topic "DOCKER ABSTRACTION" "Docker rmi succeeded. \"${image}:${version}\" image removed"
  else
    debug --level 2 --topic "DOCKER ABSTRACTION" "Docker rmi failed."
  fi
  return $sucess
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
    # run the docker command in the foreground (no hooks are run in this case)
    debug --level 5 --topic "DOCKER ABSTRACTION" "docker_run (no-fork)[image:${image}][version:${version}][flags:${flags}][command:${command}] ==> docker run ${daemon} ${flags} ${image}:${version}  ${command}"    
    docker run ${flags} ${image}:${version} ${command}
  else
    # run the docker command and capture the container ID
    debug --level 5 --topic "DOCKER ABSTRACTION" "docker_run (fork)[image:${image}][version:${version}][flags:${flags}][command:${command}] ==> docker run ${daemon} ${flags} ${image}:${version}  ${command}"
    container="`docker run ${daemon} ${flags} ${image}:${version} ${command}`"

    local success=$?
    if [ $success == 0 ]; then
      debug --level 5 --topic "DOCKER ABSTRACTION" "RESULTS of docker run => container started [ID:$container]"

      # execute any existing hooks
      debug --level 7 --topic "DOCKER ABSTRACTION" "Running run_post hooks => hooks_execute start --state \"run_post\" --image \"${image}\" --version \"${version}\" --container \"${container}\""
      hooks_execute start --state "run_post" --image "${image} --version "${version} --container "${container}"
    else
      debug --level 2 --topic "DOCKER ABSTRACTION" "Docker run failed. Not running any hooks"
    fi
    return $success
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
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_attach [container:${container}][flags:${flags}] ==> docker attach ${flags} ${container}"
  docker attach ${flags} ${container}
  local success=$?
  if [ $success == 0 ]; then
    debug --level 6 --topic "DOCKER ABSTRACTION" "Docker attach succeeded. \"${container}\" container was attached"
  else
    debug --level 2 --topic "DOCKER ABSTRACTION" "Docker attach failed."
  fi
  return $sucess
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
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_start [container:${container}][flags:${flags}] ==> docker start ${flags} ${container}"
  docker start ${flags} ${container}
  local success=$?
  if [ $success == 0 ]; then
    debug --level 6 --topic "DOCKER ABSTRACTION" "Docker start succeeded. \"${container}\" container started"
  else
    debug --level 2 --topic "DOCKER ABSTRACTION" "Docker start failed."
  fi
  return $sucess
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
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_stop [container:${container}][flags:${flags}] ==> docker stop ${flags} ${container}"
  docker stop ${flags} ${container}
  local success=$?
  if [ $success == 0 ]; then
    debug --level 6 --topic "DOCKER ABSTRACTION" "Docker stop succeeded. \"${container}\" container stopped"
  else
    debug --level 2 --topic "DOCKER ABSTRACTION" "Docker stop failed."
  fi
  return $sucess
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

  # execute any existing hooks
  debug --level 7 --topic "DOCKER ABSTRACTION" "Running pre hooks => hooks_execute rm --state pre --container \"${container}\""
  hooks_execute rm --state pre --container "${container}"

  # Run docker command
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_rm [container:${container}][flags:${flags}] ==> docker rm ${flags} ${container}"
  docker rm ${flags} ${container}
  local success=$?
  if [ $success == 0 ]; then
    debug --level 6 --topic "DOCKER ABSTRACTION" "Docker rm succeeded. \"${container}\" container removed"

    # execute any existing hooks
    debug --level 7 --topic "DOCKER ABSTRACTION" "Running post hooks => hooks_execute rm --state post --container \"${container}\""
    hooks_execute rm --state post --container "${container}"
  else
    debug --level 2 --topic "DOCKER ABSTRACTION" "Docker rm failed."
  fi
  return $sucess
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

  # execute any existing hooks
  debug --level 7 --topic "DOCKER ABSTRACTION" "Running pre hooks => hooks_execute commit --state pre --image \"${image}\" --version \"${version}\" --container \"${container}\""
  hooks_execute attach --state pre --image "${image}" --version "${version}" --container "${container}"

  # Run docker command
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_commit [image:${image}][version:${version}][container:${container}][flags:${flags}] ==> docker commit ${container} ${image}:${version}"
  docker commit ${flags} ${container} ${image}:${version}
  local success=$?
  if [ $success == 0 ]; then
    debug --level 6 --topic "DOCKER ABSTRACTION" "Docker commit succeeded. \"${container}\" container committed to ${image}:${version}"

    # execute any existing hooks
    debug --level 7 --topic "DOCKER ABSTRACTION" "Running post hooks => hooks_execute commit --state post --image \"${image}\" --version \"${version}\" --container \"${container}\""
    hooks_execute attach --state post --image "${image}" --version "${version}" --container "${container}"
  else
    debug --level 2 --topic "DOCKER ABSTRACTION" "Docker commit failed."
  fi
  return $sucess
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
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_inspect [container:${container}][flags:${flags}] ==> docker inspect ${flags} ${container}"
  docker inspect ${flags} ${container}
  local success=$?
  return $sucess
}

#
# Pause a running container`
#
# -c|--container : container ID or name
#
# @TODO parameter validation
# @TODO test if the container exists and is running
# @TODO test if the container is not paused already
docker_pause()
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
      -*) echo >&2 "docker_pause(): unknown flag $1 : pause -c|--container {container}";;
      *)
        break;; # terminate while loop
    esac
    shift
  done

  # Run docker command
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_pause [container:${container}][flags:${flags}] ==> docker pause ${flags} ${container}"
  docker pause ${flags} ${container}
  local success=$?
  if [ $success == 0 ]; then
    debug --level 6 --topic "DOCKER ABSTRACTION" "Docker pause succeeded. \"${container}\" container was paused"
  else
    debug --level 2 --topic "DOCKER ABSTRACTION" "Docker pause failed."
  fi
  return $sucess
}

#
# Un-Pause a paused  container`
#
# -c|--container : container ID or name
#
# @TODO parameter validation
# @TODO test if the container exists and is running
# @TODO test if the container is paused
docker_unpause()
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
      -*) echo >&2 "docker_unpause(): unknown flag $1 : unpause -c|--container {container}";;
      *)
        break;; # terminate while loop
    esac
    shift
  done

  # Run docker command
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_unpause [container:${container}][flags:${flags}] ==> docker unpause ${flags} ${container}"
  docker unpause ${flags} ${container}
  local success=$?
  if [ $success == 0 ]; then
    debug --level 6 --topic "DOCKER ABSTRACTION" "Docker unpause succeeded. \"${container}\" container was unpaused"
  else
    debug --level 2 --topic "DOCKER ABSTRACTION" "Docker unpause failed."
  fi
  return $sucess
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
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_top [container:${container}][flags:${flags}] ==> docker top ${flags} ${container}"
  docker top ${flags} ${container}
  local success=$?
  return $sucess
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
  debug --level 5 --topic "DOCKER ABSTRACTION" "docker_logs [container:${container}][flags:${flags}] ==> docker logs ${flags} ${container}"
  docker logs ${flags} ${container}
  local success=$?
  return $sucess
}

#
# Check if an image exists,
#
# -i|--image {image} : image to filter for, you can add a version "${image}:${version}"
# -a|--all : @NOTE removed - this would search all build commits, which is really not something we want.
# -q|--idonly : return only image IDs
#
inspect_docker_image_list()
{
  # filter text for grep
  local filter=""

  # start with an empty argument list
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -i|--image)
        filter="${2}"
        shift
        ;;
      -q|--idonly)  flags="$flags --quiet";;
      -*) echo >&2 "docker_image_list(): unknown flag $1 : inspect_docker_image_list [-q|--idonly] [-i|--image {image}]";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Run docker command
  if [ -n $image ]; then
    debug --level 9 --topic "DOCKER ABSTRACTION" "inspect_docker_image_list [flags:${flags}][filter:${filter}] ==> docker images ${flags} | grep -i \"${filter}\""
    echo "`docker images ${flags} | grep -i "${filter}"`"
  else
    debug --level 9 --topic "DOCKER ABSTRACTION" "inspect_docker_image_list [flags:${flags}] ==> docker images ${flags}"    
    echo "`docker images ${flags}`"
  fi
}

# check if docker image $1 exists (has been built)
_docker_image_exists()
{
  local image=$1
  local exists="`inspect_docker_image_list --image ${image}`"
  debug --level 6 --topic "DOCKER ABSTRACTION" "_docker_image_exists [image:${image}] ==> inspect_docker_image_list --image ${image} ==> ${exists}"

  if [ $? ] && [ -n "$exists" ]; then
    return 0
  else
    return 1
  fi
}
# check if any docker containers using image $1 are running
_docker_image_running()
{
  local image=$1
  local running="`inspect_docker_container_list --running --image ${image}`"
  debug --level 6 --topic "DOCKER ABSTRACTION" "_docker_image_running [image:${image}] ==> inspect_docker_container_list --running --image ${image} ==> ${running}"

  if [ $? ] && [ -n "${running}" ]; then
    return 0
  else
    return 1
  fi
}

#
# Check if a container exists - and if it is running
#
# -c|container {container} : container name or ID to filter for (@NOTE Filter arg)
# -i|--image {image} : image name to filter for (@NOTE Filter arg)
#
# -r|--running : only check for running containers
# -q|--id : return only the container ID
#
# @NOTE while this has multiple filter options, it only handles one at a time
# @NOTE if not filters are passed, 
#
# @TODO allow retrieval of just specific fields from docker_ps
# @TODO make this function handle multiple filters per execution.
inspect_docker_container_list()
{
  # assume we want to check even for containers that are not running
  local all="--all"
  # start with an empty argument list
  local flags=""
  # text for which we will grep
  local filter=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        filter="$2"
        shift
        ;;
      -i|--image)
        filter="$2"
        shift
        ;;
      -q|--idonly)  flags="$flags --quiet";;
      -r|--running)  all="";;
      -*) echo >&2 "docker_container_list(): unknown flag $1 : exists [-c|--container {container}] [-q|--idonly] [-r|--running] -c|--container {container} ]";;
      *)
          break;; # terminate while loop
    esac
    shift
  done

  # Run docker command
  local result=""
  local success=0
  if [ -n $container ]; then
    # PRINTING This debug will break the function
    debug --level 9 --topic "DOCKER ABSTRACTION" "inspect_docker_container_list listing the docker container => docker ps ${flags} ${all} | grep -i ${filter}"
    # @NOTE I debated about the grep -i flag, but ignoring case-collision in container name seems to be best.
    echo "`docker ps ${flags} ${all} | grep -i ${filter}`"
  else
    # PRINTING This debug will break the function
    debug --level 9 --topic "DOCKER ABSTRACTION" "inspect_docker_container_list listing the docker container => docker ps ${flags} ${all}"
    echo "`docker ps ${flags} ${all}`"
  fi
}

# check if docker container $1 exists (has ever been started with `docker run`)
_docker_container_exists()
{
  local container=$1
  local exists="`inspect_docker_container_list --container $container`"
  debug --level 6 --topic "DOCKER ABSTRACTION" "_docker_container_exists [container:$container] ==> inspect_docker_container_list --container $container ==> ${exists}"

  if [ $? ] && [ -n "$exists" ]; then
    return 0
  else
    return 1
  fi
}
# check if docker container $1 is running
_docker_container_running()
{
  local container=$1
  local running="`inspect_docker_container_list --running --container $container`"
  debug --level 6 --topic "DOCKER ABSTRACTION" "_docker_container_running [container:$container] ==> inspect_docker_container_list --running --container $container ==> ${running}"

  if [ $? ] && [ -n "$running" ]; then
    return 0
  else
    return 1
  fi
}
