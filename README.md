
# DOCKER MANAGEMENT TOOLS


## WHAT IS THIS

This is a quick version of what vagrant is, but tailored for Docker
This toolset is a container management framework for docker
which is meant to give a fast headstart to creating a docker
based development server.

### WHAT IS DOCKER

Docker is a Linux chroot library, that is ultra efficient, and uses some
fancy linix code to make really efficient isolated environments.

### WHY NOT VIRTUALBOX

Well, if you're reading this on a Mac, then you'll need VBOX anyway, but
if not, here is a list of advantages:

- shared disk space for static components of your box
    e.g. all centos boxes use the same base layer of centos OS and userland
- nested images
    children images can all be based of various parents, and share customizations
    made to those containers
- separation of image and container
    - you can run multiple containers of the same image
- no need to rebuild most of the container (like the web-server)
- containers are really fast to start and stop
- you can consider not using ssh
- containers use much less reasources

### WHY NOT USE VAGRANT

Vagrant is probably a good idea, in fact it is a much more mature
and stable solution than this ...

BUT 

There are a few things that this
toolset does/could eventually provide that VAGRANT cannot.)

- versioning containers (snapshots, reversion, forking)
- temporary containers (run a self-destructing test container)
- provision rarely, share often
- share containers (as images) with content/data in them
- separated provisioning (no need to reprovision adding php-fpm or nginx base)
  from operation.
- folders/files from different containers can be shared across
  containers (different machine versions can share things)

### HOW IS THIS DIFFERENT FROM VAGRANT

1. you only need a small project specific provision/build ... kind of

Docker images are nested, and persistant, and can be the base for a container.
This means that if you build something generic. it can be used for all sorts
if children.  This means that provisioning can be separated into stages
This is what our dev image parent does:

1. wwwserver
 - A centOS 65 image with nginx, php-fpm, mariaDB and sshd, that uses supervisor to manage servers
2. wwwserver-dev (which we use a "parent")
 - the wwwserver image with a developer user added, git, drush, zsh and some other things,
   it also modifies some of the php settings for more verbosity, and adds xdebug,
   and adds specific .ssh credentials

3. project
 - a project specific image that puts site's nginx configuration into place, and adds
   a mariaDB database, and it adds the project source (1 time copy) into the build
   also drush aliases

The third image can be built on top the first (production) or the second (development)

2 Containers are based on the images

Any container that runs, will start with the image contents, and from there can be fleshed out
to add content, drush sql-sync etc.  A container can be temporary, but it can also be marked/commited
to a new version of the base image (and the name can be custom, or just the "latest"

A container is like a copy of what you have when you run vagrant up, after provisioning

3. Containers have a life of their own

Container can be:
- temporary and disappear after you shut them down
- marked as new base images, either as new versions or as the latest version of the image

## The architecture

### the project layout

The current configuration has certain expectations what files and folders are required, and for where things should be:

/source/  <- where your project source is assumed to be
  www <- The default web root, where the default nginx configuration expects to host a project site.

/manage/ <- a root folder where all of the scripts and configurations for the project are kept (this repository!)
  control <- the principle control script, which can run all the commands.
  _utilities.sh <- a file with various tool functions.
  _docker.sh <- abstraction for docker control, has functions for different docker operations.

  commands/ <- contains 1 file per control command, with named function to implement the command, or provide help.
  hooks/ <- a series of nested folders, each folder corresponding to a hook label.  In the folders are any number of scripts which are run as hooks.

  build/  <- folder containing various docker container configuration
  build/container <- docker container configuration : built on a parent, tailors the image to have project specific configurations
  build/parent/ <- docker parent container configuration : a generic dev container with nginx, php etc.

/* whatever else you want

### "control" : the management script

All of the management tools are worked into a single script manage/control.  The control script switches based on a command argument, and uses functions from the _docker.sh script to run docker commands.  Control has some base default configuration in it's header, and inludes overridable configurations from _settings.sh.   The control script is smart enough that it doesn't need to executed from any particular folder.

The general control syntax is:

./manage/control {global args} {command} {command args}

global args:
 -v|--verbose [{0-9}] : enable debugging on all operations, pick a verbosity (1-9, 5 is default, 9 is most verbose)
 -l|--log [{0-9}] : enable debug logging on all operations, pick a verbosity (default is 9), log file path is in /manage/data/log
 -f|--force : don't stop when an error occurs

The Commands are abstracted files in the manage/commands folder, with a {command}_execute method.  These files are 'source'd into scope

For a list of commands try this:
$/> manage/control help
$/> manage/control help {command}

### them images

The build system is not aware of dependencies.

The default approach is to have a parent image shared across projects/containers.  You should build any dependencies first; if you include the build configurations then the build command will help you doing that, but you will have to know the order of dependencies, and run the command once per dependency.

#### the parent image: wwwerver-cnpm-dev

The parent image is used as a base for all projects using this framework.  It has the basic docker functionality, with www server applications installed, and configured to run.

The parent is CentOS 6.5 based, using nginx, php-fpm, mariaDB, running alsoo sshd, managed by supervisor

The base Docker container is included as a Dockerfile in the manage/build/parent folder.  This only needs to be built once per host machine, and can be built using the build command.

@BUGS:
- Supervisor sometimes uses 100% CPU, I think that is not playing well with nginx.  I am considering switching to using simplevisor, which has less features but is more efficient.  Using simplevisor would mean losing the tcp client.

#### the project image

The build system builds a custom image for your project, using the parent as a shared base.  Then you project iself can be versioned (multiple versions) and used for multiple containers.

## A quick start

1. STEP ZERO : You probably already did this

  - Fork (git branch) or export this repo;

2. STEP ONE : BUILD YOUR PROJECT CONTAINER

  Q: Do you have the parent box?
    If you don't then the build will pull it.  If you want you can build it first with $/> manage/control build --build {parent}

  - Play with the contents of manage/_settings.sh if you want
  - Play with the container build configuration (manage/build/container)
  - Add your project source, probably to /source (unless you want to really play with the container configuration)
  - RUN $/> manage/control [-v] build

3. STEP TWO : Run the container

  - RUN $/> manage/control [-v] start
    (the first time this is run, it will create a container, other times it should resume it)

4. OPTIONAL STEPS

  - To get help RUN $/> manage/control help {command}
    (there are lots of options, which should be investigated, especially for commit)
  - To stop a container RUN $/> manage/control [-v] stop
  - To see the output of a running container RUN $/> manage/control [-v] attach
  - To save a changed container back to the image RUN $/> manage/control [-v] commit
  - To get a temporary shell in a new container (for debugging) $/> manage/control [-v] shell

# QUICK FAQ

Why can't I start my container:

  - did you build first
  - did you run any funky customizations that failed the build?
       - check that the image was created
       - check the build output for an error

Why does my container use 100%

  - we have a problem with supervisord taking 100% CPU, I haven't
    figured out why yet.

I started my container but I don't see it?

  - are you expecting a prompt or output, because the default conf
    doesn't provide any

I used the shell command, but my changes disappear

  - shell is meant to provide a temporary container based on the image
       - you can try --persistant to have the container stay
  - shell gives you a new container, not the same container
    as you have in start.  
  - shell is meant as a tools to debug the 
    container, or to make changes that are then commited to the
    image.

I don't like the file layout, how do I change it?

  - The top of the control script has a number of bash variables pointing to the various elements.  You could change those
  - if you don't like the source/www system, then feel free to remove it, but make sure to adjust the volume mounts, and nginx configuration as well.
