# Project DockerFile
#
# Site/Project specific image for the project
# Built on top of the wwwserver-cnpm build
#
FROM jamesnesbitt/www-cnpm-jn-dev
MAINTAINER James Nesbitt <james.nesbitt@wunderkraut.com>

# run as root user - as we will use supervisor to manage the container
USER    root
ENV     HOME /root

# Update php conf (not reall necessary, but left here for demo)
ADD     etc/php.ini /etc/php.ini

# Add nginx conf for the source
ADD     etc_nginx_confd/project.conf /etc/nginx/conf.d/project.conf

# Add developer home folder overrides
ADD     home_developer /home/developer
RUN     /bin/chown -R developer:developer /home/developer/.ssh
RUN     /bin/chmod -R go-rwx /home/developer/.ssh && \
        /bin/chmod go+r /home/developer/.ssh/* && \
        /bin/chmod go-rwx /home/developer/.ssh/id_rsa

# Make the databases (first start the maria server - which can take up to 5 seconds)
RUN     (/usr/bin/mysqld_safe &) && sleep 5 
RUN     mysql -uroot -e "CREATE DATABASE project; \
        GRANT ALL ON project.*  TO project@localhost IDENTIFIED BY 'project'; \
        GRANT ALL ON *.* to project@0.0.0.0 identified by 'project';"
