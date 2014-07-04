#
#
# Multiline runs are used to minimize RUN transactions to keep the cache
# shorter for this basebox.  There is no need to overdo the caching here.
#
FROM            centos:latest
MAINTAINER      james.nesbitt@wunderkraut.com

## EPEL Dependency on CentOS 6 and Red Hat (RHEL) 6 ##
RUN curl -O http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    rpm -Uvh epel-release-6*.rpm && rm epel-release-6*.rpm && \
    yum update -y && yum clean -y all

# Install the mimimum services required to get a base platform (ssh service generates keys)
RUN yum install -y openssh-server && \
    sed -i -e '/pam_loginuid\.so/ d' /etc/pam.d/sshd
# run the sshd service once to create the server keys
RUN service sshd start
EXPOSE 22

# Install MariaDB
ADD etc_yum.repos.d/mariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN yum install -y MariaDB-server && \
    mkdir /var/run/mysqld && \
    chown mysql /var/run/mysqld
RUN mysql_install_db && chown -R mysql:mysql /var/lib/mysql && (/usr/bin/mysqld_safe &) && sleep 5 && \
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO root@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
EXPOSE 3306

# Install nginx (make it run as the nginx user)
ADD etc_yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo
RUN yum install -y nginx
RUN chown -R nginx:nginx /var/log/nginx && \
    chmod -R ug+rwX /var/log/nginx
ADD etc_nginx_nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443

# Install php-fpm (libX11 and libX11-common come with php-gd)
RUN yum update -y && \
    yum --enablerepo=remi,remi-php55 install nginx -y php-fpm php-common \
    php-pecl-apc php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongo \
    php-ldap php-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring \
    php-mcrypt php-xml php-mysql
ADD etc_php-fpm.conf /etc/php-fpm.conf
ADD etc_php-fpm.d_www.conf /etc/php-fpm.d/www.conf
ADD etc_php.ini /etc/php.ini
RUN chown -R nginx:nginx /var/log/php-fpm && \
    chmod -R ug+rwX /var/log/php-fpm && \
    chown nginx /var/run/php-fpm

# Install Drush
RUN yum install -y which php-drush-drush

# Create a place for the web project
ADD app /app
RUN /bin/chown -R :nginx /app

# Install the simplevisor
# simplevisor dropped cause it uses perl to read confs.  I am modding it for YAML but it won't be an offical build
# Simplevisor would be much better as it can handle init.d/rc.d runs, which are much more competent than running
# binaries manually.
# Currently we have some PERL related issued that are preventing use of simplevisor
#
#RUN yum install -y python-simplevisor
#ADD etc_simplevisor.conf.d /etc/simplevisor.conf.d
#CMD /usr/bin/simplevisor --conf /etc/simplevisor.conf

# supervisor (simplevisor would be better as it handles "service start" commands
RUN yum install -y supervisor
ADD etc_supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/run/supervisor
EXPOSE 9001

# Command that will run when the server starts
USER root
CMD ["/usr/bin/supervisord --conf=/etc/supervisord.conf --nodaemon"]

#
# DEVELOPER TOOLS
#
# Evertything below here should be disabled if building this image for server
# environments, and you dont want the developer user or tools in place.
#

# Add more developer PHP tools
RUN yum install -y  php-pecl-xdebug

# Overload the php conf for dev settings
ADD etc_php-fpm.d_www.conf /etc/php-fpm.d/www.conf
ADD etc_php.ini /etc/php.ini

# Create a developer user
# Put whatever you want into this folder, maybe .ssh credentials, drush, etc
ADD home_developer /home/developer
RUN yum install -y wget git zsh sudo vim && \
    adduser -d /home/developer -M -u 1000 -G wheel -s /bin/zsh -p "developer" -c "development login" developer && \
    chown -R developer:developer /home/developer && \
    echo "developer        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    gpasswd -a nginx developer && \
    gpasswd -a developer nginx

