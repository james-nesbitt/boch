#!bin/sh
#
# COMMAND: commit a container to an image
#

# Command help function
commit_help()
{
  echo "
commit an existing container to a new version

 -c|--container : specify which container to commit to the image
 -i|--image : specify an image name to commit to
 -v|--version : specify an image version to commit to

@TODO check for existing container
"
}

# Command execute function
commit_execute()
{
  #default values
  container=${Docker_container}
  image=${Docker_image}
  version=${Docker_imageversion}

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
      -*)
        echo >&2 "unknown flag $1 : commit [-i|--image] {image} [-v|--version] {version} [-c|--container] {container}"
        exit
        ;;
      *)
        break;
    esac
    shift
  done

  # Run the commit function
  debug --level 5 --topic "COMMAND" "commit [ handing off to docker abstraction ] ==> docker_commit --image \"${image}\" --version \"${version}\" --container \"${container}\""
  docker_commit --image "${image}" --version "${version}" --container "${container}"
  return $?
}
