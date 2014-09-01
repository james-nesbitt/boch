#
# Multiline runs are used to minimize RUN transactions to keep the cache
# shorter for this basebox.  There is no need to overdo the caching here.
#
FROM            jamesnesbitt/www-cnpm-jrn
MAINTAINER      james.nesbitt@wunderkraut.com

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
    gpasswd -a developer nginx && \
    gpasswd -a developer mysql
