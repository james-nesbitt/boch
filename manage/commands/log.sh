#!bin/sh
#
# COMMAND: Output control logs
#

# command help function
log_help()
{
  echo "
Output the control logs

The prints the control logs for this management control process.

 -t|--tail : make this a tail process
 -f|--follow : make this a tail process, and follow it.
"
}

# command execute function
log_execute()
{
  # Log path
  local path="${path_log}"

  # Command
  local com="cat"
  # Flags
  local flags=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      -t|--tail)
        com="tail"
        ;;
      -t|--tail)
        com="tail"
        flags="${flags} -f"
        ;;
      -*)
        echo >&2 "unknown flag $1 : log [-t|--tail] [-f|--follow]"
        exit
        ;;
      *)
        break;
    esac
    shift
  done

  # Run the logs function
  debug --level 5 --topic "COMMAND" "log [ executing log output command ][command:${command}][flags:${flags}] ==> ${com} ${flags} \"${path}\""
  eval "${com} ${flags} ${path}"
  return $?
}
