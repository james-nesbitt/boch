#
# COMMAND: Get access to a shell running on a certain image
#

# Command help function
shell_help()
{
  echo "
Give shell access to a new container based on the image
this does not term into a running container, but rather
creates a new container and gives shell access to it
"
}

# Command execute function
shell_execute()
{
  image="${Docker_image}"
  version="${Docker_imageversion}"
  hostname="${Machine_hostname}"

  # temp.  empty this to make the shell a persistant container
  temp="--temporary"

  flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -c|--container)
        flags="${flags} --name $2"
        shift
        ;;
      -h|--hostname)
        hostname="${2}"
        shift
        ;;
      -i|--image)
        image="${2}"
        shift
        ;;
      -r|--persistant)
        temp=""
        ;;
      -v|--version)
        version="${2}"
        shift
        ;;
      *)
        break;
    esac
    shift
  done

  # use the machine shell or pass in a command
  command=${@:-${Machine_shell}}

  # add default flags to the end of the flag list
  flags="${flags} ${Machine_shellrunargs} ${Machine_mountvolumes}"

  # Run the shell function
  debug --level 5 --topic "COMMAND" "shell [ handing off to docker abstraction ] ==> docker_run ${flags} ${temp} --shell "${Machine_shell}" --image "${image}" --version "${version}" --allports ${Machine_mountvolumes} $@"
  docker_run ${temp} --shell "${Machine_shell}" --image "${image}" --version "${version}" --hostname "${hostname}" ${flags} $@
  return $?
}
