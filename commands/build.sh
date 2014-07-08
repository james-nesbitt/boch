#!bin/sh
#
# COMMAND: Build a new image:version for a project
#

# command help function
build_help()
{
  echo "
Build or destroy docker images related to the project.

  -b|--build {build} : select a different build from the ${path_build} folder

  -d|--destroy : delete/destroy the build instead of building it

  -i|--image {image} : overrides settings image name for new image
  -v|--version {version} : overrides settings image version for new image

@TODO check to see if image:version is running before removing it.
"
}

# command execute gunction
build_execute()
{
  # default build settings
  local path="${path_build}/project"
  local image="${Docker_image}"
  local version="${Docker_imageversion}"

  # build or destroy
  local action="build"

  while [ $# -gt 0 ]
  do
    case "$1" in
      -b|--build)
        local build=$2
        shift
        # Run the build buildfunction for the parent instead of the project
        path="${path_build}/${build}"
        image="${Docker_image}_${build}"
        version="latest"
        ;;
      -d|--destroy)
        action="destroy"
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
        echo >&2 "unknown flag $1 : build [-p|--parent]"
        break;; # terminate while loop
    esac
    shift
  done

  if [ "$action" == "destroy" ]; then    # test to see if the build exists
    if [ ! _docker_image_exists "${image}:${version}" ]; then
      debug --level 1 --topic "COMMAND" "build :: error destroying custom image, image doesn't exist: ${image}:${version}"
    fi
    if [ ! _docker_image_running "${image}:${version}" ]; then
      debug --level 1 --topic "COMMAND" "build :: error destroying custom image, image has running containers: ${image}:${version}"
    fi

    # run the rmi method
    debug --level 5 --topic "COMMAND" "build :: destroying custom image [ handing off to docker abstraction ] ==> docker_rmi --image ${image} --version ${version}"
    docker_rmi --image "${image}" --version "${version}"
    return $?
  else
    # test to see if the build exists
    if [ ! -d ${path} ]; then
      debug --level 1 --topic "COMMAND" "build :: error building custom image, path to build doesn't exist: ${path}"
    fi

    # Run the build function
    debug --level 5 --topic "COMMAND" "build :: building custom image [ handing off to docker abstraction ] ==> docker_build --image ${image} --version ${version} ${path}"
    docker_build --image "${image}" --version "${version}" "${path}"
    return $?
  fi
}
