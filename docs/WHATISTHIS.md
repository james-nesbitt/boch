
# DOCKER MANAGEMENT TOOLS

## WHAT IS THIS

This is a bash version of what vagrant is, but tailored for Docker
This toolset is a container management framework for docker
which is meant to give a fast headstart to creating a docker
based development server.

### WHAT IS DOCKER

Docker is a Linux chroot library, that is ultra efficient, and uses some
fancy linix code to make efficient secure isolated environments.

### WHY NOT VIRTUALBOX

Well, if you're reading this on a Mac, then you'll need VBOX anyway, but
here is a list of advantages compared to VMs:

- shared disk space for static components of your box (real dedup)
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

  @TODO Talk about nested images and Dockerfiles

2 Containers are based on the images

  Any container that runs, will start with the image contents, and from there can be fleshed out
  to add content, drush sql-sync etc.  A container can be temporary, but it can also be marked/commited
  to a new version of the base image (and the name can be custom, or just the "latest"

  A container is like a copy of what you have when you run vagrant up, after provisioning

3. Containers have a life of their own

Container can be:
- temporary and disappear after you shut them down
- marked as new base images, either as new versions or as the latest version of the image

## HOW DO I USE THIS

### Installation ###

Check the INSTALLATION document

### "boch" : the management scripts ###

The general script syntax is:

 boch {global args} {library} {library args}

global args:
 -h|--help : get help on an implementation instead of runnign it
 -v|--verbose [{0-9}] : enable debugging on all operations, pick a verbosity (1-9, 5 is default, 9 is most verbose)
 -l|--log [{0-9}] : enable debug logging on all operations, pick a verbosity (default is 9), log file path is in /manage/data/log
 -f|--force : don't stop when an error occurs

Some examples:

 - boch command ps     (shortcut : boch ps)

 - boch flow status    (shortcut : boch status)

 - boch flow init      (shortcut : boch init)

 - boch help

 * add -h for help instead of action

### How can I get help information ###

For more information for each script try asking for help:

 - boch help help:init

 - boch help help:libraries

 - boch help command:general

 - boch help flow:general

 - boch help {any library}:general

 * Any help topic will list other topics that can be searched for in (round brackets)
