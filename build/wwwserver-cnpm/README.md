= README =

This is a docker image that is used as a base www server

The following components are used:

- latest centos7 docker base image
- latest nginx.repo nginx webserver
- latest centos7 php-fpm
- latest epel php libraries
- latest centos7 mariadb (5.0 branch)

The docker run binary is supervisord as provided by the EPEL
library.

You can install the image locally by running the build.sh
script (the test.sh will give you a temporary shell inside
the image,) but it will likely be build by the control
script automatically.

Elements of the build:

- Include the EPEL repository
- Install supervisord and add the individual program ini files
- Install mariadb-server, run the mysql_install_db (note that matching supervisord conf)
- Add the nginx repo, and install nginx. Add the nginx conf
- Install php-fpm, and various commonly used php libraries
- Install drush (no aliases yet)
- Create a root /app folder for the web application(s) give nginx/php-fpm access to it

Note the various configuration files available, which are inserted into the build.
