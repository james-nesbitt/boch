#!bin/sh
#
# COMMAND: Show status for a container
#

# Help function
status_help()
{
 echo "
Show the status for a container

A status function to check operational status of a docker container
and or an image.
You can filter to a specific image, and/or a specific container.
Actually, you are expected to filter to either container or a filter, 
otherwise we will assume your want the default/active container/image

  -i|--image {image} : specify which image to limit to
  -c|--container {container} : specify which container to limit to

@NOTE if neither image nor container are passed, the default container
    image pair are used.
@TODO give more help information, about the tables that are exported.
"
}

# command execute function
status_execute()
{
  # optional container to limit to
  container=""
  # optional image to limit to
  image=""

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
        image="${2}"
        shift
        ;;
      -*)
        echo >&2 "unknown flag $1 : status [-i|--image {image}] [-c|--container {container}]"
        exit
        ;;
      *)
        break;
    esac
    shift
  done

  if [ -z $image ] && [ -z $container ]; then
    #set to the default/active image and container
    image=${Docker_image}
    container=${Docker_container}
  fi

  # 
  debug --level 5 --topic "COMMAND" "status check starting [image:${image}][container:${container}]"

  # Check the image
  if [ "${image}" != "" ]; then
    debug --level 7 --topic "COMMAND" "status check of image starting [image:${image}]"
    echo "IMAGE INSPECT:"
    echo "=============="

    if _docker_image_exists ${image}; then
      echo "--> IMAGE EXISTS"

      if _docker_image_running ${image}; then
        echo "--> IMAGE IS RUNNING"
      else
        echo "--> IMAGE IS NOT RUNNING"
      fi

      # Output the image table, with this filter
      echo "IMAGE LIST TABLE:"
      echo "REPOSITORY                        TAG                 IMAGE ID            CREATED             VIRTUAL SIZE (Including shared)"
      inspect_docker_image_list --image ${image}
    else
      debug --level 7 --topic "COMMAND" "status check of image starting [image:${image}]"
    fi
  else
    echo "IMAGE DOES NOT EXIST (try using this: $/> manage/control build)"
  fi
  # check the container
  if [ "${container}" != "" ]; then
    debug --level 5 --topic "COMMAND" "status check of container starting [container:${container}]"
    echo "CONTAINER INSPECT:"
    echo "=================="

    if _docker_container_exists ${container}; then 
      echo "--> CONTAINER EXISTS" 

      if _docker_container_running ${container}; then 
        echo "--> CONTAINER IS RUNNING" 
      else
        echo "--> CONTAINER IS NOT RUNNING"
      fi

      # Output the container list with this filter

      echo "CONTAINER ID        IMAGE                       COMMAND             CREATED             STATUS              PORTS                                         NAMES"
      inspect_docker_container_list --container "${container}"
    else
      echo "CONTAINER DOES NOT EXIST. Try using this: $/> manage/contol start"
    fi
  else
    debug --level 7 --topic "COMMAND" "status check of container skipped (no container declared, but an image was)"
  fi
}
