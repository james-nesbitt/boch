#
#
# Multiline runs are used to minimize RUN transactions to keep the cache
# shorter for this basebox.  There is no need to overdo the caching here.
#
FROM            debian:wheezy
MAINTAINER      mikelis.zalais@wunderkraut.com

# dns
#ADD conf/resolv/resolv.conf /etc/resolv.conf

# Upgrade system
#ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

# Setup system and install tools
RUN echo "initscripts hold" | dpkg --set-selections
RUN apt-get -qqy install libreadline-gplv2-dev libfreetype6 apt-utils dialog
RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN echo 'alias ll="ls -lah --color=auto"' >> /etc/bash.bashrc
RUN apt-get -qqy install passwd supervisor git-core sudo unzip wget curl libfile-slurp-perl libmysql-diff-perl vim net-tools software-properties-common python-software-properties bzip2

# Set locale
#RUN apt-get -qqy install locales
#RUN locale-gen --purge de_DE de_DE.UTF-8
#RUN locale-gen --purge en_US en_US.UTF-8
#RUN dpkg-reconfigure locales
#ENV LC_ALL en_US.UTF-8

# Setup ssh
RUN apt-get -qqy install openssh-server
RUN mkdir -p /var/run/sshd
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN echo 'root:root' |chpasswd

# Configure git
ADD conf/git/.gitconfig /home/dev/.gitconfig

# Generate a host key before packing.
RUN service ssh start; service ssh stop

# Apache
RUN apt-get -qqy install apache2-mpm-prefork apache2-utils
RUN a2enmod rewrite
#RUN mkdir /etc/apache2/conf.d/
RUN echo "ServerName localhost" | tee /etc/apache2/conf.d/fqdn
ADD conf/apache/000-default /etc/apache2/sites-enabled/000-default


# PHP
RUN apt-get -qqy install libapache2-mod-php5 php5 php5-cli php5-mysql php5-curl php5-dev php5-gd php-pear php-apc php5-xdebug
ADD conf/php/php.ini /etc/php5/apache2/php.ini

# Add drush
RUN apt-get -qqy install drush

# Setup xdebug
RUN echo "xdebug.remote_enable=1" >> /etc/php5/mods-available/xdebug.ini
RUN echo "xdebug.remote_autostart=0" >> /etc/php5/mods-available/xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /etc/php5/mods-available/xdebug.ini
RUN echo "xdebug.remote_port=9000" >> /etc/php5/mods-available/xdebug.ini

# Add supervisor config
ADD conf/supervisor/debian-lamp.conf /etc/supervisor/conf.d/debian-lamp.conf

# Mysql
RUN apt-get -qqy install mysql-server mysql-common mysql-client
ADD conf/mysql/my.cnf /etc/mysql/my.cnf
RUN mysql_install_db && chown -R mysql:mysql /var/lib/mysql && (/usr/bin/mysqld_safe &) && sleep 5 && \
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO root@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# phantomjs
RUN cd /usr/local/share
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2
RUN tar xjf phantomjs-1.9.7-linux-x86_64.tar.bz2
RUN ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/share/phantomjs
RUN ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
RUN ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/bin/phantomjs

# Make the databases
RUN     (/usr/bin/mysqld_safe &) && sleep 5 && \
        mysql -uroot -e "CREATE DATABASE project; GRANT ALL ON project.*  TO project@localhost IDENTIFIED BY 'project';"

# Load sql
ADD     db/database.mysql /root/database.mysql
RUN     (/usr/bin/mysqld_safe &) && sleep 5 && \
        mysql -uroot project < /root/database.mysql

# Disable backups
RUN     (/usr/bin/mysqld_safe &) && sleep 5 && \
        mysql -uroot -e "USE project; \
        UPDATE backup_migrate_schedules SET enabled=0; \

# fix private folder
RUN     (/usr/bin/mysqld_safe &) && sleep 5 && \
        mysql -uroot -e "USE project; \
        INSERT INTO variable VALUES ('file_private_path', X'733A32313A2273697465732F64656661756C742F70726976617465223B');"

# development nice things
# disable update checking
# reset password to admin/admin
RUN     (/usr/bin/mysqld_safe &) && sleep 5 && \
        mysql -uroot -e "USE project; \
        INSERT INTO role_permission VALUES (1, 'access devel information', 'devel'); \
        UPDATE system SET status=0 WHERE name='update'; \
        INSERT INTO role_permission VALUES (1, 'access language en', 'language_access');"

RUN     (/usr/bin/mysqld_safe &) && sleep 5 && \
        mysql -uroot -e 'USE project; \
        UPDATE users SET name="admin", pass="$S$DLS58JQpP/vJLEk3nogKCGBnhGmfKxTSUOMIK3.eYq.3Ryq19HtH" where uid=1;'


# Install xhprof

# enable devel performance output


EXPOSE 22 80 3306

CMD ["/usr/bin/supervisord", "-n"]
