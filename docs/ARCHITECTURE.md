= The architecture =

The architecture of this toolset is very thin and abstracted.  Most of the work is done in
abstracted tool libraries, that are loaded with library_include.  The core libraries are found
in the /libraries folder, BUT any library can have it's own libraries folder, and the custom
folder for the project settings is considered a library, so you can easily add your own libraries.

== Layout ==

=== The core architecture  ===

_init  : a core include to load libraries and stuff
_utilities : a set of tool functions like debug/log and include_source
_libraries : tools used to manage libraries and library components

There are two executable scripts in the toolset
control : a straight forward implement command script
flow : a more abstracted execution, heavily hook dependent (so easily expanded)

libraries/  <-- the core libraries
  command/  <-- command handler libraries with commands/{command} components
                * commands are library components, so you can add a /commands
                  folder to any library, including your project
  docker/   <-- docker implementations, low level docker function handlers
  flow/     <-- flow handlers, really just lots of hooks
  hooks/    <-- the hooks library with functions for running hooks
  help/     <-- a library with functions for getting help
  settings/ <-- a library for configuring the toolset, and for making a default config

  wwwserver/ <-- a custom library that is includes settings related to our custom docker builds


=== Project folder architecture ==

Your project folder is a place to put custom settings for your project, 
and where you can add custom hooks, libraries and commands.
It is also where certain libraries like to keep information on containers
created etc.

* You don't need to create this folder, you can have it created for you:
  $/> manage/flow init --name {some_name} --wwwserver

Layout:

/project       <-- this name is currently fixed.
  settings     <-- a script with settings in it
  builds/      <-- a folder that should container various custom docker builds
                   for your project

  [hooks/]     <-- an optional folder hooks implementations
  [commands/]  <-- an optional folder for custom commands for you project
  [libraries/] <-- an optional folder for project libraries/plugins

== The tool core scripts ==

There are two primary executable scripts in the toolset. 

- control : a straightforward implementation that tries to implement 
    a single command;
- flow : a more abstract workflow script, designed around hook implementations
    to perform more abstract operations.

=== "control" : the management script ===

All of the management commands are worked into a single script manage/control.  The control script switches based on a command argument, but in general it ends up using functions from the _docker.sh script to run docker commands.  Control has some base default configuration options, and inludes overridable configurations from the command line, and from your project settings.   The control script is smart enough that it doesn't need to executed from any particular folder.

The general control syntax is:

./manage/control {global args} {command} {command args}

global args:
 -v|--verbose [{0-9}] : enable debugging on all operations, pick a verbosity (1-9, 5 is default, 9 is most verbose)
 -l|--log [{0-9}] : enable debug logging on all operations, pick a verbosity (default is 9), log file path is in /manage/data/log
 -f|--force : don't stop when an error occurs

The Commands are abstracted files in the manage/commands folder, with a {command}_execute method.  These files are 'source'd into scope

For a list of commands try this:
$/> manage/control --help
To get help with a particular command try this:
$/> manage/control --help {command}

=== flow : the workflow management script ===

The flow script differs greatly from the control script, both in intention and implementation.  Conceptually, flows are broader worklflow implementations as opposed to single operations, and have less direct connection to spcific commands, or docker operations.  A good example is the "init" flow, which will give you your custom project folder.
Flows are entirely hook based, meaning that they exist as long as a single matching hook exists.

The general flow syntax is:

./manage/flow {global args} {flow/subflow/subsubflow} {flow args}

global args:
 -v|--verbose [{0-9}] : enable debugging on all operations, pick a verbosity (1-9, 5 is default, 9 is most verbose)
 -l|--log [{0-9}] : enable debug logging on all operations, pick a verbosity (default is 9), log file path is in /manage/data/log
 -f|--force : don't stop when an error occurs

hooks for flows will be in
 hooks/flow/{flow}/{subflow}/{subsubflow}  with a /pre  and a /post folder used as well.

== Images and builds ==

Any library can have a builds folder, in which are individual build folders for docker. Each build folder has to have a Dockerfile in it, but can also have any files that are to be copied into the image during build.

By default there is a single build in the system called template, which is based on our wwwserver-cpnm-dev image, hosted on Dockerio.  If you want access to more of the related tools and settings, consider including the wwwserver library in you settings (or including the --wwwserver flag when running ./flow init)

For more info check the readme files in the wwwserver library or the template build.
