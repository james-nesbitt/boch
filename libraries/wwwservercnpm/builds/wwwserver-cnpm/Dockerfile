#
# Multiline runs are used to minimize RUN transactions to keep the cache
# shorter for this basebox.  There is no need to overdo the caching here.
#
FROM            centos:centos7
MAINTAINER      james.nesbitt@wunderkraut.com

# Update core
RUN /usr/bin/yum update -y && yum clean -y all

# Install some tools used here.
RUN /usr/bin/yum install -y wget curl git tar unzip

## EPEL Dependency on CentOS 6 and Red Hat (RHEL) 6 ##
RUN wget http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-0.2.noarch.rpm && \
    rpm -ivh epel-release-7-0.2.noarch.rpm && rm epel-release-7-0.2.noarch.rpm && \
    yum update -y && yum clean -y all

# Install supervisord
RUN /usr/bin/yum install -y supervisor
#ADD etc_supervisord.conf /etc/supervisord.conf
ADD etc_supervisord.d /etc/supervisord.d
EXPOSE 9001

# Install the mimimum services required to get a base platform (ssh service generates keys)
RUN /usr/bin/yum install -y openssh-server && \
    sed -i -e '/pam_loginuid\.so/ d' /etc/pam.d/sshd && \
    /usr/bin/ssh-keygen -A
EXPOSE 22

# Install MariaDB
RUN /usr/bin/yum install -y mariadb-server mariadb
ADD etc_my.cnf.d_server.cnf /etc/my.cnf.d/server.cnf
ADD etc_my.cnf /etc/my.cnf
RUN /usr/bin/mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --log-error=/var/log/mariadb/error.log --pid-file=/var/run/mariadb/mariadb.pid --socket=/var/run/mariadb/mariadb.sock --bind=0.0.0.0 --port=3306
EXPOSE 3306

# Install nginx (make it run as the nginx user)
ADD etc_yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo
RUN /usr/bin/yum install -y nginx
RUN chown -R nginx:nginx /var/log/nginx && \
    chmod -R ug+rwX /var/log/nginx
ADD etc_nginx_nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443

# Install php-fpm (libX11 and libX11-common come with php-gd)
RUN /usr/bin/yum install -y php-fpm php-common \
    php-pecl-apc php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongo \
    php-ldap php-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring \
    php-mcrypt php-xml php-mysqlnd
ADD etc_php-fpm.conf /etc/php-fpm.conf
ADD etc_php-fpm.d_www.conf /etc/php-fpm.d/www.conf
ADD etc_php.ini /etc/php.ini
RUN chown -R nginx:nginx /var/log/php-fpm && \
    chmod -R ug+rwX /var/log/php-fpm && \
    chown nginx /var/run/php-fpm

# Install Drush
RUN /usr/bin/yum install -y php-drush-drush

# Create a place for the web project
ADD app /app
RUN /bin/chown -R :nginx /app

# Command that will run when the server starts
USER root
CMD /usr/bin/supervisord --nodaemon --configuration /etc/supervisord.conf
