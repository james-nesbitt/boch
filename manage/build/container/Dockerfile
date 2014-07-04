# Project DockerFile
#
# Site/Project specific image for the project
# Built on top of the wwwserver-cnpm build
#
# Note that there is a non-dev deployment version of the
# Parent image that can be used for deployment
# jamesnesbitt/wwwserver-cnpm
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

# Add an ssh setup for the user from conf (done during build to get ssh in and out permissions)
ADD     dev_dotssh /home/developer/.ssh
RUN     /bin/chown -R developer:developer /home/developer/.ssh
RUN     /bin/chmod go-rwx /home/developer/.ssh

# ADD Drush aliases
ADD     etc_drush /home/developer/.drush
RUN     mkdir /home/developer/dumps
RUN     /bin/chown -R developer:developer /home/developer/.drush && \
        /bin/chown -R developer:developer /home/developer/dumps

# ADD BM Specific tools
ADD     dev_bin /home/developer/bin
RUN     /bin/chown -R developer:developer /home/developer/bin

# Make the databases
RUN     (/usr/bin/mysqld_safe &) && sleep 5 && \
        mysql -uroot -e "CREATE DATABASE project; GRANT ALL ON project.*  TO project@localhost IDENTIFIED BY 'project';"
