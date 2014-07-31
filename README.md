
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

@TODO update layout description

### "command" : the management script

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

### "flow" : the workflow management script

@TODO describe the flow command

### them images

The build system is not aware of dependencies.

The default approach is to have a parent image shared across projects/containers.  You should build any dependencies first; if you include the build configurations then the build command will help you doing that, but you will have to know the order of dependencies, and run the command once per dependency.

#### the parent image: wwwerver-cnpm-dev

The parent image is used as a base for all projects using this framework.  It has the basic docker functionality, with www server applications installed, and configured to run.

The parent is CentOS 7 based, using nginx, php-fpm, mariaDB, running alsoo sshd, managed by supervisor

The base Docker container is included as a Dockerfile in the manage/build/parent folder.  This only needs to be built once per host machine, and can be built using the build command.

#### the project image

The build system builds a custom image for your project, using the parent as a shared base.  Then you project iself can be versioned (multiple versions) and used for multiple containers.

## A quick start

@TODO Update for new library system

# QUICK FAQ

Why can't I start my container:

  - did you build first
  - did you run any funky customizations that failed the build?
       - check that the image was created
       - check the build output for an error

I started my container but I don't see it?

  - are you expecting a prompt or output, because the default conf doesn't provide any

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
