#!bin/sh
#
# COMMAND: Build multiple images
#

# command help function
build_multiple_help()
{
  echo "
Build or destroy multiple docker images.

By default, images from the \$Docker_builds variable are built 
(\${Docker_builds}=${Docker_builds:-"project"} )

  -b|--build {builds} : select a different build from the \${path_build} folder
        This can be a space separated, ordered list of builds in the folder,
        which will be built.
        (\${path_build}=${path_build} )
        The last of the list will be considered the base image, on which containers
        will be built.  The base image will be given the image name and version.
  -f|--force : build the images, even if they exist, overwriting existing images

  -d|--destroy : delete/destroy the image instead of building it.

  -i|--image {image} : name to use for the new base image, overriding the default.
  -v|--version {version} : version to use for the new base image, overriding the
        default.
@NOTE this was forked off of the \"build\" command, as it has different flags for 
  implementation, that got confusing with mixing single and multiple builds.
@NOTE because the -b flag takes a space separated list, be careful of how you pass
  your parameters.  The -b flag assumes that any parameter starting with - is the
  next flag
"
}

# command execute gunction
build_multiple_execute()
{
  # default build settings
  local basepath="${path_build}"
  local builds="${Docker_builds:-"project"}"

  local version=""
  local force=""

  # build or destroy
  local action="build"

  # local flags
  local flags=""
  while [ $# -gt 0 ]
  do
    case "$1" in
      -b|--build)
        # Override what builds to build
        builds=""
        while [ $# -gt 0 ]
        do
          case "$2" in
            -*)
              break;;
            *)
              builds="${builds} $2"
              shift
              ;;
          esac
        done
        ;;
      -f|--force)
        flags="${flags} --force"
        ;;
      -d|--destroy)
        action="destroy"
        ;;
      -v|--version)
        version="${flags} --version ${2}"
        shift
        ;;
      *)
        echo >&2 "unknown flag $1 : build -b|--builds {builds} [-v|--version {version}] [-f|--force]"
        break;; # terminate while loop
    esac
    shift
  done

  # include the build command, whose hooks we will reuse
  _include_command "build"

  if [ "$action" == "destroy" ]; then    # test to see if the build exists
    for build in $builds; do
      debug --level 5 --topic "COMMAND" "build_multiple :: removing image ${image} (flags:${flags})"
      build_destroy --image ${image} ${flags}
    done
  else
    local path=""
    for build in $builds; do
      debug --level 5 --topic "COMMAND" "build_multiple :: building image ${image} (path:${path})(flags:${flags})"
      build_build --path "${basepath}/${build}" --image ${image} ${flags}
    done
  fi
}
