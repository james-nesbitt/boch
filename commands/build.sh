#!bin/sh
#
# COMMAND: Build a new image[:version] for a project
#

# command help function
build_help()
{
  echo "
Build or destroy a project related docker image.

The intention with this command is to build the project specific
image, which will then be used as a base image for all project containers
This base image can then be forked into different version, for different
purposes.

Another use of the function is to build/rebuild/destroy one of the required
parent images, that are the basis of the project specific container.
If you keep all of your builds in the \${path_build} folder, then they
can easily be built by passing the individual folder names to this command.

  -b|--build {build} : override the build, the path to the Dockerfile
    (as a sub-path of the build directory: ${path_build})

  -d|--destroy : delete/destroy the image instead of building it

  -i|--image {image} : overrides settings image name for new image
  -v|--version {version} : overrides settings image version for new image

@NOTE by default, the only image build will be the single project specific
  image (${path_build}/${default_build:-"project"})
@NOTE the latest docker_build function uses \"latest\" as the default
  image version.
"
}

# command execute function
build_execute()
{
  # default build settings
  local path="${path_build}/${default_build:-"${Docker_image:-"project"}"}"
  local image="${Docker_image}"
  local version="${Docker_imageversion}"

  # build or destroy
  local action="build"

  # local flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -b|--build)
        path="${path_build}/${2}"
        image="${2}"
        version="latest"
        shift
        ;;
      -d|--destroy)
        action="destroy"
        ;;
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
        echo >&2 "unknown flag $1 : build [-b|--build {build}}] [-d|--destroy] [-f|--force] [-i|--image {image}] [-v|--version {version}]"
        break;; # terminate while loop
    esac
    shift
  done

  # build on the flags (valid for both create and destroy)
  flags="--image ${image}"
  if [ -z ${version} ]; then
    flags="${flags} --version ${version}"
  fi

  if [ "$action" == "destroy" ]; then    # test to see if the build exists
    build_destroy ${flags}
    return $?
  else
    build_build ${flags} --path "${path}"
    return $?
  fi
}


# destroy function
#
# @TODO add --force action: which would force it to be deleted
build_destroy()
{
  # don't force delete images by default
  local force=0

  # local flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -f|--force)
        force=1
        flags="${flags} --force"
        ;;
      -i|--image)
        local image="${2}"
        flags="${flags} --image ${image}"
        shift
        ;;
      -v|--version)
        local version="${2}"
        flags="${flags} --version ${version}"
        shift
        ;;
      *)
        echo >&2 "unknown flag $1 : build_destroy [-f|--force] -i|--image {image} -v|--version {version}"
        break;; # terminate while loop
    esac
    shift
  done

  local tag="${image}"
  if [ -z $version ]; then
    tag="${tag}:${version}"
  fi

  if ! _docker_image_exists "${tag}"; then
    if [ force -eq 0 ]; then
      debug --level 1 --topic "COMMAND->build" "build_destroy() :: error destroying custom image, image doesn't exist: ${image}:${version}"
    else
      debug --level 1 --topic "COMMAND->build" "build_destroy() :: image doesn't exist, trying to delete anyway (because of --force): ${image}:${version}"
    fi
  fi
  if ! _docker_image_running "${image}:${version}"; then

    if [ force -eq 0 ]; then
      debug --level 1 --topic "COMMAND->build" "build_destroy() :: error destroying custom image, image has running containers: ${image}:${version}"
    else
      debug --level 4 --topic "COMMAND->build" "build_destroy() :: trying to destroy custom image that has running containers (because of --force): ${image}:${version}"
    fi
  fi

  # run the rmi method
  debug --level 5 --topic "COMMAND->build" "build_destroy() :: destroying custom image [ handing off to docker abstraction ] ==> docker_rmi ${flags}"
  docker_rmi ${flags}
  return $?
}

# build function
#
# @note --image and --version are optional, --path is required
build_build()
{
  # don't force buld existing images
  local force=0

  # local flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -f|--force)
        force=1
        flags="${flags} --force"
        ;;
      -p|--path)
        local path="${2}"
        shift
        ;;
      -i|--image)
        local image="${2}"
        flags="${flags} --image ${image}"
        shift
        ;;
      -v|--version)
        local version="${2}"
        flags="${flags} --version ${version}"
        shift
        ;;
      *)
        echo >&2 "unknown flag $1 : build_build [-f|--force] -i|--image {image} -v|--version {version} -p|--path {path}"
        break;; # terminate while loop
    esac
    shift
  done

  local tag="${image}"
  if [ -z $version ]; then
    tag="${tag}:${version}"
  fi

  if _docker_image_exists "${tag}" ; then
    if [ force -eq 0 ]; then
      debug --level 1 --topic "COMMAND->build" "build_build() :: error building custom image, image already exists: ${tag}"
    else
      debug --level 4 --topic "COMMAND->build" "build_build() :: image already exists, forcing build anyway due to force flag: ${tag}"
    fi
  fi

  # test to see if the build exists
  if [ ! -d ${path} ]; then
    debug --level 1 --topic "COMMAND->build" "build_build() :: error building custom image, path to build doesn't exist: ${path}"
  fi

  # Run the build function
  debug --level 5 --topic "COMMAND->build" "build_build() :: building custom image [ handing off to docker abstraction ] ==> docker_build ${flags} --path ${path}"
  docker_build ${flags} --path "${path}"
  return $?
}
