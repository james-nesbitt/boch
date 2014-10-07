= The template build =

This is the www-cnpm-jn-dev template build.  It is from the www-cnpm-jn library, and uses builds bases on the parents www-cnpm-jn and www-cnpm-jn-dev, both of which are available hosted in docker.io (jamesnesbitt/.)
The template is based in the docker.io hosts build, which docker will pull/use when you build.

Description of the build:
- the parent-parent is a CentOS build that uses nginx, php-fpm. mariadb (5), managed using supervisord.  SSHD is installed.  No passwords are set, as CENTOS containers don't play well with passwd.
- the parent build adds a developer user, and some developer resources like xdebug and the ruby bundler gem;
- this build by default tries to add an nginx host file for this project, adds some rsa stuff for the particular image, adds a new database, and includes a developer user bin folder with some scripts.

== What to customize before building ==

You should really consider modifying this biuld before building, unless you want to rely on the default project url, nginx, php configuration, and the default DB parameters.

Consider modifying the contents of this folder in your project file (not in the source boch library), after you run the init flow, but before you run the build.

The help page for the init flow has more information about this process.
$/> boch help flow:init
OR
$/> boch --help flow init

=== The Dockerfile ===

You should review the Dockerfile, and add any scripts or files that you want included in the build.

- You should customize the database creation script as you want
- You should remove any elements that you don't want
- You should consider ADDing the entire source folder, for server deployment builds

=== SSH stuff ===

You should consider completely replace the developer ssh stuff, in the dev_dotssh folder.  There is a separate README in that folder with instructions.

You should at least change the authorized_keys folder, or you should live mount overtop of the keys folder (the prior is a better options.)

=== NGINX conf ===

The nginx conf in etc_nginx_confd/project.conf will be installed during the build of this container.  You should change the host/URL path used, and maybe replace the entire declaration.
The existing sample is very Drupal specific.

=== php configuration ===

You should consider changing the etc_php.ini file as needed.

=== dot_drush ===

You should remove, or customize the drush aliases container here to match you local and remote Drupal configurations.

=== bin ===

The bin folder is added to the developer's home folder, so it can contain any scripts that make sense.
