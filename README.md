wwwerver-cnpm-dev
=================

wwwerver-cnpm-dev

A docker based development environment

CentOS 6.5 based, using nginx, php-fpm, mariaDB, running alsoo sshd, managed by supervisor

The base Docker container is included as a Dockerfile in the manage/dockerparent folder.  This only needs to be built once per host machine.

@BUGS:
- Supervisor sometimes uses 100% CPU, I think that is not playing well with nginx.  I am considering switching to using simplevisor, which has less features but is more efficient.  Using simplevisor would mean losing the tcp client.

Management
From the host you can use the manage/manage.sh to create the base container
