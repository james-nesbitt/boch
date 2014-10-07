#
# Multiline runs are used to minimize RUN transactions to keep the cache
# shorter for this basebox.  There is no need to overdo the caching here.
#
FROM            jamesnesbitt/www-cnpm-jn
MAINTAINER      james.nesbitt@wunderkraut.com

#
# DEVELOPER TOOLS
#
# Evertything below here should be disabled if building this image for server
# environments, and you dont want the developer user or tools in place.
#

# Add more developer PHP tools
RUN /usr/bin/yum install -y  php-pecl-xdebug

# Add sass stuff, but based on ruby 2.0
RUN /usr/bin/yum install -y ruby rubygems rubygem-bundler

# Overload the php conf for dev settings
ADD etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf
ADD etc/php.ini /etc/php.ini

# Create a developer user
# Put whatever you want into this folder, maybe .ssh credentials, drush, etc
ADD home/developer /home/developer
RUN /usr/bin/yum install -y openssl zsh sudo vim && \
    adduser -d /home/developer -M -u 1000 -G wheel -s /bin/zsh -p "`echo "developer" | openssl passwd -1 -stdin`" -c "development login" developer && \
    chown -R developer:developer /home/developer && \
    echo "developer        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    gpasswd -a nginx developer && \
    gpasswd -a developer nginx && \
    gpasswd -a developer mysql
