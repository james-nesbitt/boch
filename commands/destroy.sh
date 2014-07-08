#!bin/sh
#
# COMMAND: Destroy a built project or parent image
#

# Command help functoin
destroy_help()
{
  echo "
Destroy a built image

  -i|--image : use a different image name to commit to
  -v|--version : use a different image version to commit to

@TODO check for existing container
"
}

# Command execute function
destroy_execute()
{
  image=${Docker_image}
  version=""
  container=${Docker_container}

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
        # @NOTE that this may break your -i and -v settings, depending on order
        path="${path_buildparent}"
        image="${Docker_parentimage}"
        version="latest"
        ;;
      -*)
        echo >&2 "unknown flag $1 : destroy [ [-i|--image] {image} [-v|--version] {version} | [-p|--parent] ] "
        exit
        ;;
      *)
        break;
    esac
    shift
  done

  # Run the commit function
  debug --level 5 --topic "COMMAND" "destroy [ handing off to docker abstraction ] ==> docker_rmi --image ${image} --version ${version}"
  docker_rmi --image "${image}" --version "${version}"
  return $?
}
