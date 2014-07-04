wwwerver-cnpm-dev
=================

wwwerver-cnpm-dev

A docker based development environment

CentOS 6.5 based, using nginx, php-fpm, mariaDB, running alsoo sshd, managed by supervisor

The base Docker container is included as a Dockerfile in the manage/dockerparent folder.  This only needs to be built once per host machine.

@BUGS:
- Supervisor sometimes uses 100% CPU, I think that is not playing well with nginx.  I am considering switching to using simplevisor, which has less features but is more efficient.  Using simplevisor would mean losing the tcp client.

/source/  <- where your project source should be
  www <- The default web root, where the default nginx configuration expects to host a project site.

/manage/ <- a root folder where all of the scripts and configurations for the project are kept.
  control <- the principle control script, which can run all the commands
  _settings.sh <- a script that has some overrides for the control script settings
  _utilities.sh <- a file with various tool functions
  _docker.sh <- abstraction for docker control, has functions for different docker operations.

  commands/ <- contains 1 file per control command, with named function to implement the command, or provide help

  build/  <- folder containing various docker container configuration
  build/container <- docker container configuration : built on a parent, tailors the image to have project specific configurations
  build/parent/ <- docker parent container configuration : a generic dev container with nginx, php etc.

Management
All of the management tools are worked into a single script manage/control.  The control script switches based on a command argument, and uses functions from the _docker.sh script to run docker commands.  Control has some base default configuration in it's header, and inludes overridable configurations from _settings.sh.   The control script is smart enough that it doesn't need to executed from any particular folder.

The general control syntax is:

./manage/control {global args} {command} {command args}

global args:
 -v|--verbose : enable debugging on all operations

some example commands (these could be out of date, try manage/control help for up to date assistance)
  build [-p|--parent] : build the container based on the dockerfile in /manage/docker (or manage/dockerparent)
  start [--image {image}] [--version {version}] [--container {container}] : start a (new) container using the image
  stop [--image {image}] [--version {version}] [--container {container}] : stop a running container using the image
  shell [--persistent] [--image {image}] [--version {version}] [--container {container}] : open a shell in a temporary container using the image
  commit [--image {image}] [--version {version}] [--container {container}] : save a running container as a new image

STEP ZERO : You probably already did this

- Fork (git branch) or export this repo;

STEP ONE : BUILD YOUR PROJECT CONTAINER

Q: Do you have the parent box?
  If you don't then the build will pull it.  If you want you can build it first with --parent

- Play with the contents of manage/_settings.sh if you want
- Play with the container build configuration (manage/build/container)
- Add your project source, probably to /source (unless you want to really play with the container configuration)
- RUN $/> manage/control [-v] build

STEP TWO : Run the container

- RUN $/> manage/control [-v] start
  (the first time this is run, it will create a container, other times it should resume it)

OPTIONAL STEPS

- To get help RUN $/> manage/control help {command}
  (there are lots of options, which should be investigated, especially for commit)
- To stop a container RUN $/> manage/control [-v] stop
- To see the output of a running container RUN $/> manage/control [-v] attach
- To save a changed container back to the image RUN $/> manage/control [-v] commit
- To get a temporary shell in a new container (for debugging) $/> manage/control [-v] shell

For More information look in manage/README
