= README =

Documentation is in the /docs folder. This readme is a quick intro.

This folder contains a set of tools that can be used to control docker images
to support a project.  The toolset starts off with a simple approach, but is 
geared towards a more complex mix of images and containers for a project.

Typical file layouts used:

project_root/
  manage/   <-- the code from this toolset that you checked out
  source/   <-- your actual source code for your project

  project   <-- toolset settings for your particular project
                (you can automatically generate this, see below)


Typical workflow for starting a project:

1. Checkout source-code and this toolset together
   $/> git clone {source} source
   $/> git clone {this toolset} manage

2. Initialize the project settings
   $/> manage/flow init --name "{a_name_for_this_project}" --wwwserver

     -> the --name presets an image name, a build name, and some container names
     -> the --wwwserver includes our centos based box tools and settings

    * this creates the following:
      /project/
         settings     <-- script that has settings for the project
         builds/
            {name}    <-- a docker build for your project

3. Customize the settings for your project:

    - edit any of the files in /project
    - change any of the configurations in /project/settings
      - in particular remove any of it (leave the lines that start with ## SETTINGS FROM HOOK)
    - configure your base docker box
      - change the name of the nginx conf file when copied into the host?
      - alter the php.ini to change php-fpm settings for your image
      - alter the nginx.conf as you may need
      - add/alter the Dockerfile RUN commands to customize you DB, or any other tricks.
      - change the project/builds/{name}/dev_dotssh/ files, especially authorized_keys (allows ssh into the box)

      * errors in the changes to the build are easily discovered in the next step

4. Build your base project

  $/> manage/control build

5. Start your first container

  $/> manage/control start

  then ssh in using this:

  $/> manage/control ssh

Other tools that are available:

A. Get a status report on your images and containers:

  $/> manage/flow status

B. Stop/Restart a container

  $/> manage/control stop
  $/> manage/control start


C. get help

  $/> manage/control --help 
  $/> manage/flow --help

  $/> manage/control --help {command}
  $/> manage/flow --help {flow}

*. Advanced stuff

Start a second container

  $/> manage/control start --container "{different container name}"

  now all of the other commands can control this container with the same --container {name} flag

Commit changes from a container to an image (all new containers will contain that change)

  $/> manage/control commit [--container {which source container}] [--image {which image}] [--version {image tag/version}]

  * this can be used to fork the image

Get shell access to a temporary container using the image (great for testing the image, and testing changes - but don't commit it)

  $/> manage/control shell

