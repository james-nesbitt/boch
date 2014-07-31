
COMMANDS

Commands are shell script function sets, used to implement control commands

The file should have the following methods:

${command}_help() : print out some help text.  Will be used with control help {$command} $@
${command}_execute() : Run the command.  Will be used with control {$command} $@

