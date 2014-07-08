#!bin/sh
#
# COMMAND: Build a new image:version for a project
#

# command help function
build_help()
{
  echo "
build the project docker image, from the docker build file
located in the docker build directory.

  -i|--image : overrides settings image name for build
  -v|--version : overrides settings image version for build
  -p|--parent : build parent instead of the project image

@TODO - --parent might not play well with --image and --version
@TODO - build the parent if it is not found, instead of using the flag!
"
}

# command execute gunction
build_execute()
{
  path="${path_build}/container"
  parent_image="${Docker_image}_parent"
  image="${Docker_image}"
  version="${Docker_imageversion}"

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
      -p|--parent)
        # Run the build function for the parent instead of the project
        path="${path_build}/parent"
        image="${Docker_parentimage:-$parent_image}"
        version="latest"
        ;;
      *)
        echo >&2 "unknown flag $1 : build [-p|--parent]"
        break;; # terminate while loop
    esac
    shift
  done

  # Run the build function
  debug --level 5 --topic "COMMAND" "build [ handing off to docker abstraction ] ==> docker_build --image ${image} --version ${version} ${path}"
  docker_build --image "${image}" --version "${version}" "${path}"
  return $?
}
