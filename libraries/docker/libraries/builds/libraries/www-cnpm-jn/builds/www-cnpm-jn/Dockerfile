#
# Multiline runs are used to minimize RUN transactions to keep the cache
# shorter for this basebox.  There is no need to overdo the caching here.
#
FROM            centos:latest
MAINTAINER      james.nesbitt@wunderkraut.com\

# Update and clean
RUN /usr/bin/yum update -y && /usr/bin/yum clean -y all && /usr/bin/yum -y makecache

# Install some tools used here.
RUN /usr/bin/yum install -y epel-release wget curl git tar unzip hostname

# Install the mimimum services required to get a base platform (ssh service generates keys)
RUN /usr/bin/yum install -y openssh-server && \
    sed -i -e '/pam_loginuid\.so/ d' /etc/pam.d/sshd && \
    /usr/bin/ssh-keygen -A
EXPOSE 22

# Install MariaDB
RUN /usr/bin/yum install -y mariadb-server mariadb
ADD etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf
ADD etc/my.cnf /etc/my.cnf
RUN /usr/bin/mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --log-error=/var/log/mariadb/error.log --pid-file=/var/run/mariadb/mariadb.pid --socket=/var/run/mariadb/mariadb.sock --bind=0.0.0.0 --port=3306
# Rassafrakkin' php-mysql doesn't want to look anywhere else, php-mysqlnd doesn't play well with drupal
RUN ln -s /var/run/mariadb/mariadb.sock /var/lib/mysql/mysql.sock
RUN (/usr/bin/mysqld_safe &) && sleep 5 && mysql -uroot -e "GRANT ALL ON *.* to project@172.17.42.1 identified by 'project';"
EXPOSE 3306

# Install nginx (make it run as the nginx user)
ADD etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo
RUN /usr/bin/yum install -y nginx
RUN chown -R nginx:nginx /var/log/nginx && \
    chmod -R ug+rwX /var/log/nginx
ADD etc/nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443

# Install php-fpm (libX11 and libX11-common come with php-gd)
RUN /usr/bin/yum install -y php-fpm php-common \
    php-pecl-apc php-cli php-pear php-pdo php-mysql php-pgsql php-pecl-mongo \
    php-ldap php-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring \
    php-mcrypt php-xml php-pecl-yaml
ADD etc/php-fpm.conf /etc/php-fpm.conf
ADD etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf
ADD etc/php.ini /etc/php.ini
RUN chown -R nginx:nginx /var/log/php-fpm && \
    chmod -R ug+rwX /var/log/php-fpm && \
    chown nginx /var/run/php-fpm

# Install Drush
RUN /usr/bin/yum install -y php-drush-drush

# Install supervisord
RUN /usr/bin/yum install -y supervisor
ADD etc/supervisord.d /etc/supervisord.d
EXPOSE 9001

# Create a place for the web project
ADD app /app
RUN /bin/chown -R :nginx /app

# Command that will run when the server starts
USER root
CMD /usr/bin/supervisord --nodaemon --configuration /etc/supervisord.conf
