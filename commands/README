
COMMANDS

Commands are shell script function sets, used to implement control commands

The file should have the following methods:

${command}_help() : print out some help text.  Will be used with control help {$command} $@
${command}_execute() : Run the command.  Will be used with control {$command} $@

This approach means that commands can be simple or complex.  Simple commands will use the 
_execute function to implement all required functionality, while complex commands will use
_execute as a switchboard, and accept subcommands:
  control ${command} ${command args} ${sub-command} ${sub-command args}

The file will be include automatically if it matches control ${command}, but can be included
manually from other places using the utility function _include_command ${command} $@
This incude ability allows for commands to include utility functions of their own that could
be usefull to other commands/hooks
