= The architecture =

This toolset is an entirely POSIX compliant (I think) bash/shell toolset that should work without
problems on most systems except maybe WINDOWS (hardcoded file paths use the wrong slash.)
All used files in the system are included using source, and the inclusion will only include executable
files, to allow for documentation and other files to be mixed in.

The toolset can be installed either directly into a single project folder, or installed globally on
a system (recommended.)

== libraries ==

The architecture of this toolset is very abstracted.  Most of the effort is handled in abstracted
library tools, which can contain a variety of implemented functionaly through includes and sub-folders.
The abstraction is handled in such a way, that usually any library can contain other functionality.  An
example of the abstraction is that any library can container a libraries folder, which can make new
libraries.
At a bare minimum, a library is defined as either a single executable script (anywhere) or a folder
which an executable script that matches the folder in name (without any "." characters.  A folder
without the executable script, is treated as a non-existant library.
Important core libraries are: docker, boot2docker, command, flow, settings and help; described later.

The toolset root is itself treated as a library, so it's /libraries folder is used as a source of
libraries, and treated like any other library (but used as the last place to look.)
Each project (optionally) has a root boch/ project folder, that contains project specific functionality.
This folder is treated as a library so it gains all of the advantages of a library.  If the toolset is
installed globally, then this is how the toolset identifies a project root, by looking for the project
folder (similar to how git looks for .git, and vagrant looks for Vagrantfile.)
Additionally, every system user can have a ~/.boch/ folder, which is also treated as a library, that
can provide user specific functionality across all projects.

All of these libraries can container /libraries and /hooks folders, as well as /settings and /help
files to add functionality.

== hooks ==

The second key component in the toolset is the hook concept, which allows any library to include an
ordered list of files that can be run on the triggering of certain events.  The files are sorted across
all libraries, to create a single ordered list.  Again, these files must be executable, or they are
ignored.  Hooks functionality is added with the core hooks library, but is used across the system,
so the library is not optional.

== Layout ==

=== The core library architecture  ===

_init  : a core include to load libraries and stuff
_utilities : a set of tool functions like debug/log and include_source
_libraries : tools used to manage libraries and library components


There is a single command script in the system
boch : the new single command handler, that combines the 3 legacy scripts into 1
       (there shall be only 1)

There are three executable scripts in the toolset left over from the previous methodologies
control : a straight forward implement command script
flow : a more abstracted execution, heavily hook dependent (so easily expanded)
help : get help on any topic in the system

libraries/     <-- the core libraries
  command/     <-- command handler libraries with commands/{command} components
                * commands are library components, so you can add a /commands
                  folder to any library, including your project
  docker/      <-- docker implementations, low level docker function handlers
  flow/        <-- flow handlers, really just lots of hooks
  hooks/       <-- the hooks library with functions for running hooks
  help/        <-- a library with functions for getting help using library help files
  settings/    <-- a library for configuring the toolset using library /settings files
                  , and for making a default config

  boot2docker  <-- a library for integrating boot2docker implementations into the docker commands
  www-cnpm-jn/ <-- a custom library that is includes settings related to our custom docker builds

=== Project folder architecture ==

Your project folder is a place to put custom settings for your project,
and where you can add custom hooks, libraries and commands.
It is also where certain libraries like to keep information on containers
created etc.

* You don't need to create this folder, you can have it created for you:
  $/> manage/flow init --name {some_name} --libraries www-cnpm-jn

Layout:

/project       <-- this name is currently fixed.
  project      <-- a required library handler script, that can contain custom functions and
                   code, but is really only hear to make the project folder a valid library
  [settings]   <-- an optional script with settings in it, loaded before the project library is
  [help]       <-- an optional script that implements the _help and _helplist help library implementations
  [builds/]    <-- an optional  folder that should container various custom docker builds
                   for your project

  [hooks/]     <-- an optional folder hooks implementations, look at the libraries for examples
  [commands/]  <-- an optional folder for custom commands for you project
  [libraries/] <-- an optional folder for project libraries/plugins

== The tool core scripts ==

There is a new core script called "boch" which attempts to combine all of the
legacy scripts together.  Chances are you only need to use this script.

There are three primary legacy executable scripts in the toolset.

- control : a straightforward implementation that tries to implement
    a single command;
- flow : a more abstract workflow script, designed around hook implementations
    to perform more abstract operations.
- help : a target used to get help on any aspect of the system, using the various
        integrated help implemetations in the libraries and hooks.

If you use these legacy scripts then you will end up either calling the by
directly using their path, or making the globally executable in your system
by linking them to a ~/bin folder.

=== the boch script =======================

The boch commands script is an attempt to combine all of the legacy scripts into a
single script, that offers all of the previous functionality, with a more standardized
handling approach.
This toolset can be locally used from any folder, so it can be used in a project
source folder, or the toolset can be treated as a library, and the boch script can be
sourced from any ~/bin script.  There is a template in the documents for such a
bin source script

./boch {global args} {library} {library args}

global args:
 -h|--help [{help topic}] : get help on the current operation, or on a specific topic
 -v|--verbose [{0-9}] : enable debugging on all operations, pick a verbosity (1-9, 5 is default, 9 is most verbose)
 -l|--log [{0-9}] : enable debug logging on all operations, pick a verbosity (default is 9), log file path is in /manage/data/log
 -f|--force : don't stop when an error occurs

The goal of the boch script is to convert any execution as an attempt to run the
execute function of a targeted library.
The librarys used is the first argument after the global argument, but if the first
argument does not match any library, then it is matched first to a command, and if no
command is found then it is matched to a flow.
When a library has been found, the library _execute method is called to handle further
execution
If not library is matched, or if the library has no execute handler, or if the handler
returns an error, then the help handler is run.

Here are some examples:

$/> boch help command:general          --> get help about the command library
$/> boch flow init --name "myproject"  --> run the init flow
$/> boch command ps                    --> run the ps command

Here are some examples, where boch automatically matches the arguments to a library:

$/> boch start                         --> Matches to the start command
$/> boch status                        --> Matches to the status flow

As with the control and flow scripts, help can be retrieved by adding a global argument

$/> boch -h status                     --> Get help for the status flow

=== "control" : the management script =====

All of the management commands are worked into a single script manage/control.  The control script switches based on a command argument, but in general it ends up using functions from the _docker.sh script to run docker commands.  Control has some base default configuration options, and inludes overridable configurations from the command line, and from your project settings.   The control script is smart enough that it doesn't need to executed from any particular folder.

=== flow : the workflow management script ===

The flow script differs greatly from the control script, both in intention and implementation.  Conceptually, flows are broader worklflow implementations as opposed to single operations, and have less direct connection to spcific commands, or docker operations.  A good example is the "init" flow, which will give you your custom project folder.
Flows are entirely hook based, meaning that they exist as long as a single matching hook exists.

=== the help script ===

The help script is used to print help information on any passed topic.

== Images and builds ==

Any library can have a builds folder, in which are individual build folders for docker.
Each build folder has to have a Dockerfile in it, but can also have any files that are
to be copied into the image during build.

By default no images/builds are attached to a system, but the www-builds module contains
a number of options for adding builds to a project as a template.

=== www-cnpm-jn ===

there is a single build in the system called template, which is based on our www-cpnm-jn-dev
image, hosted on Dockerio.  If you want access to more of the related tools and settings,
consider including the wwwserver library in you settings (or including the
--www-builds www-cnpm-jn flag when running ./flow init)

=== www-deblamp-mz ===

A debian based build that provides a more streamlined, easier to customize build and
template.
If you want access to more of the related tools and settings,
consider including the wwwserver library in you settings (or including the
--www-builds www-deblamp-mz flag when running ./flow init)


For more info check the readme files in the wwwserver library or the template build.
