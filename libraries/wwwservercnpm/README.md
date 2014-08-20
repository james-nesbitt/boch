= The images =

The build system is not aware of dependencies, but the ${required_builds} variable can be used to indicate what builds need to be build before building the custom image for the project.

The default approach is to have a parent project image shared across projects/containers.  You should build any dependencies first; if you include the build configurations then the build command will help you doing that, but you will have to know dependencies youself.
The images used in the wwwserver-cnpm boxes are aware of their dependencies, but those dependnecies have been moved to be hosted on docker.io, so there is no need for related effort from you.

== the parent image: wwwserver-cnpm-dev ==

The parent image is used as a base for all projects using this framework.  It has the basic docker functionality, with www server applications installed, and configured to run as a development environment.

The parent is CentOS 6.5 based, using nginx, php-fpm, mariaDB, running alsoo sshd, managed by supervisor

The Dev part adds a "developer" user, some additional tools like xdebug, and more loose php settings.

You can pull the image from dockerio like this if you want to check it:
$/> docker pull jamesnesbitt/wwwserver-cpnm-dev

== The real parents ==

You can find the source builds used to build the wwwserver-cnpm-dev image in the builds folder of this library, althought you don't need to use them.
