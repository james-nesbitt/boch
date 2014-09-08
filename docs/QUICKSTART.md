# QUICKSTART #

This is a quick-start guide to getting boch working for your system

## INSTALL THE TOOLSET ##

First you must  install the project as a library somewhere on your system.

You can install the toolset anywhere, and then either directly call the
boch (or any of the legacy) script; it will determine the paths to the
toolset, the path of execution, and other important paths.
It makes sense to make a shell alias to point to the project, or to
source link the main script to an executable bin folder (one popular
example is ~/bin.)  An example of the source link script can be found
here: docs/templates/boch

The goal of this step is to be able to run $/> boch status
and see results.

At this point, the boch script is looking for the following paths:
  path_execute : the pwd directory from which the script is being executed
  path_library : the root path of the toolset
  path_userhome : the current user's home directory

  path_userconf : an optional .boch directory in the user's home directory
      which can provide additional functionality for all of the user's
      boch projects. See the docs for more information.

There is an a flow "install" which can try to perform some of these
common tasks for you.

A common way to use the flow is:
$/> boch flow install --libraries boot2docker --bin-location "user~bin"

This flow will try to:
- create a user library in ~/.boch, for functionality share across all
  projects.
- Symlink the current boch script to ~/bin/boch
- Enable the boot2docker library for all user projects (don't use that
  flag if you are not using boot2docker)

For more help about the init flow:
$/> boch help flow:install
OR
$/> boch -h flow install

## INITIALIZE YOUR PROJECT ##

### Initialize BOCH for your project ###

The boch toolset has a flow "init" which can be used to initialize a
folder as a project folder.
The goal of the init flow is to create a .boch folder in the project
root, which contains configurations and functionality for the project.

A common way to use the flow is:
$/> boch flow init --name "{name}" --www-build www-cnpm-jn

- name : is a file-safe name for the project.  If omitted, the foldername
        is used for the name value
- www-build : selects one of the sub-libraries from the www-builds libraries
        as a template build library; in this case the www-cnpm-jn library
        is used to provide a CENTOS server build, with a "developer" user
        which can be used to ssh into running containers.

This process should have created a .boch folder in the current folder,
(it may not have is one already existed in one of the parent folders)

Note that the "init" flow should be safe to run over existing projects
and can be used to update the project folder for additional cases like
using additional libraries, or building images.
If you run "init" again, and include an additional library, then that
library can modify your project settings.

### Configure BOCH for your project ###

Now that there are initial settings for your project, you should customize
those settings.  BOCH may have created these settings, but it hasn't acted
on them yet, other than to start using them locally.
For example, if you were to build an image/container now, it would run
using the template settings, which should work, but won't be very usefull
for your project, and would conflict with other projects using the same
settings.

The following stuff should likely be edited:
(some of these things are for www-cnpm-jn based projects only!)

- settings : the settings file (if created by init) should be full of all
    sorts of garbage comments, and extra settings.  You can clean those things
    up.  It will also contain redundant settings, as additional libraries
    used during init, may have added custom values to default setting vars.
    Try to leave lines that indicate settings sources. or the init flow
    will add them again, if run again.
    Some important variables here are what the image should be called, and
    what build should be used to build an image for the project.
- the build : there should be a default build in the project ./builds folder
    which will match your project name.  If there is none, then you will likey
    want a docker build there.  The --www-build flag in init is essentially
    there only to add a default build.
    - Dockerfile : edit anything in here; like the DB creation script. Also
        consider adding additional script runs for docker build.
    - dev_dotssh : come up with any RSA settings, including generating
        new certs, or adding your pub-key to the authorized_keys file.  There
        is a README in that folder.
    - etc_ngind_confd : edit this file.  You will likely only want to modify
        the URL used by nginx.
    - dev_drush : do you want real drush aliases on your project?
    - deb_bin : do you have any scripts or binaries that you want available
        inside the box, for the developer user
    - etc_php.ini : do you want different settings for PHP?

### Finalize the initialization ###

Finalizing means that we will act on all of the new project settings, and
build the first project image.

We can use the init flow to finalize, but we can also just use the build command

Using the init flow to finalize:
$/> boch flow init --finalize
(note that we usually don't have to include most of the previously used flags,
as they have hopefully already added themselves to the project, but is some cases
you should re-use all of the init flags from the previous step)

Using the build:
$/> boch command build

The output should be long, and the script should take from 10-60 seconds, as
it follows the instructions for the build.  If it needs to download (pull) an
image, then the wait will be longer.

## START A CONTAINER ##

If the builds are all finished, then starting and stopping containers should
be as simple as running:

$/> boch command start
$/> boch command stop

Containers should start and stop in as little time as it takes to start the
services running inside the container.

If your build supports ssh, then you can ssh in using:
$/> boch command ssh

You can start a 2nd container using something like this:
$/> boch command start --container "{give it a new name}"
This won't sort out IP, DNS differences for your containers, but it will give you
parrallel environments, based on the same image.

## JUST GIVE ME THE COMMANDS ##

1. init the project
$/> boch flow init --name nynewname --www-build www-cnpm-jn

2. change settings in .boch files

3. finalize the init
$/> boch flow init --name nynewname --www-build www-cnpm-jn --finalize

4. start a container
$/> boch command start

5. ssh into the container (if supported)
$/> boch command ssh

## Quick help ##

1. For more help about the install flow:
$/> boch help flow:install
OR
$/> boch -h flow install

2. For more help about the init flow:
$/> boch help flow:init
OR
$/> boch -h flow init

3. To get status on your project
$/> boch flow status
OR JUST
$/> boch status

4. To get help with the build command
$/> boch -h command build
OR
$/> boch help command:build
