= WWWSERVERCNPM Library =

This library adds support for a set of centos-nginx-phpfpm-mariadb images that have been built to offer a web-server build to the system.  The concept is to have the local system use a small build that uses one of the cnpm images as a parent, making the local build smaller, and inheriting all of the upstream functionality.

The upstream build is hosted on DOCKER.IO, but the actual builds are also locally included so that you can investigate what was done, and copy anything that you find usefull.

This library doesn't do much during execution, other than to add one of it's builds as a default template build.  This really only needs to be available during flow init.

== How To Use it ==

To use this library, and the related images, just add "library_load wwwservercnpm" to your settings file.  Alternatively, the init flow is ready to add a bunch of stuff to your system, if you include "--wwwserver" to your init run:

$/> ./flow init --wwwserver

This will add the library_load to your settings file, and it will also overload a number of settings variables with settings that match what the images require.  You should probably check the variables to see if they work for you.  This will also make the library template build the default template source for a project build.

== The Builds ==

The following dockere builds are provided by the library.

=== www-cnpm-jn ===

A centos7 image with the latest nginx, mariadb and php-fpm installed, all set up to run together in an environment that should work out of the box, if you add some project related elements such as an nginx configuration for a host.

BUG: the php-mysql library doesn't like to listen to the unix socket definition. The php lib wants the socket at /var/lib

=== www-cnpm-jn-dev ===

This image extends the www-cnpm-jn image by adding some developer oriented configurations, including things like xdebug, and adding a developer user.

=== template ====

This is a template build, that will extend the www-cnpm-jn-dev (as hosted on docker.io) with some configuration for a specific project.  It does somethings like adds a DB for the project, adds an nginx host definition to point to /app/source/www.
