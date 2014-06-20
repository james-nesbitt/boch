wwwerver-cnpm-dev
=================

wwwerver-cnpm-dev

A docker based development environment

CentOS 6.5 based, using nginx, php-fpm, mariaDB, running alsoo sshd, managed by supervisor

The base Docker container is included as a Dockerfile in the manage/dockerparent folder.  This only needs to be built once per host machine.

@BUGS:
- Supervisor sometimes uses 100% CPU, I think that is not playing well with nginx.  I am considering switching to using simplevisor, which has less features but is more efficient.  Using simplevisor would mean losing the tcp client.

/source/  <- where your project source should be
  www <- The default web root, where nginx expects to host a project site.

/manage/ <- a root folder where all of the scripts and configurations for the project are kept.
  control <- the principle control script, which can run all the commands
  _settings.sh <- a script that has some overrides for the control script settings
  _docker.sh <- abstraction for docker control, has functions for different docker operations.

  docker/  <- docker container configuration : specific settings for this container
  dockerparent/ <- docker parent container configuration : a generic dev container with nginx, php etc.

Management
All of the management tools are worked into a single script manage/control.  The control script switches based on a command argument, and uses functions from the _docker.sh script to run docker commands.  Control has some base default configuration in it's header, and inludes overridable configurations from _settings.sh.   The control script is smart enough that it doesn't need to executed from any particular folder.

The general control syntax is:

./manage/control {global args} {command} {command args}

global args:
 -v|--verbose : enable debugging on all operations

commands
  build [-p|--parent] : build the container based on the dockerfile in /manage/docker (or manage/dockerparent)

  start [--image {image}] [--version {version}] [--container {container}] : start a (new) container using the image
  stop [--image {image}] [--version {version}] [--container {container}] : stop a running container using the image

  shell [--persistent] [--image {image}] [--version {version}] [--container {container}] : open a shell in a temporary container using the image

  commit [--image {image}] [--version {version}] [--container {container}] : save a running container as a new image

STEP ONE : BUILD YOUR PROJECT CONTAINER

Q: Do you have the parent box?
  If you don't then the build will pull it.  If you want you can build it first with --parent

./manage/control [-v] build

STEP TWO : Run the container
