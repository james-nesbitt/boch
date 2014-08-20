# Project DockerFile
#
# Site/Project specific image for the project
# Built on top of the wwwserver-cnpm build
#
FROM jamesnesbitt/wwwserver-cnpm-dev
MAINTAINER James Nesbitt <james.nesbitt@wunderkraut.com>

# run as root user - as we will use supervisor to manage the container
USER    root
ENV     HOME /root

# Update php conf
ADD etc_php.ini /etc/php.ini

# Add nginx conf for the source
ADD     etc_nginx_confd/project.conf /etc/nginx/conf.d/project.conf

# ADD Drush aliases
ADD     etc_drush /home/developer/.drush
RUN     /bin/chown -R developer:developer /home/developer/.drush

# ADD Developr Specific tools, like scripts meant to be run inside the box (think build scripts)
ADD     dev_bin /home/developer/bin
RUN     /bin/chown -R developer:developer /home/developer/bin

# Add an ssh setup for the user from conf (done during build to get ssh in and out permissions)
ADD     dev_dotssh /home/developer/.ssh
RUN     /bin/chown -R developer:developer /home/developer/.ssh
RUN     /bin/chmod -R go-rwx /home/developer/.ssh && \
        /bin/chmod go+r /home/developer/.ssh/* && \
        /bin/chmod go-rwx /home/developer/.ssh/id_rsa

# Make the databases (first start the maria server - which can take up to 5 seconds)
RUN     (/usr/bin/mysqld_safe &) && sleep 5 && \
        mysql -uroot -e "CREATE DATABASE project; GRANT ALL ON project.*  TO project@localhost IDENTIFIED BY 'project'; GRANT ALL ON *.* to project@172.17.42.1 identified by 'project';"
