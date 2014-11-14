#
# Docker container for platform.sh development
#

FROM centos:centos7
MAINTAINER james.nesbitt@wunderkraut.com

# Install some base tools
RUN yum install -y tar gunzip

# Install Composer
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    /usr/bin/yum install -y php && \
    cd /root && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Make sure that the composer items are in path
RUN echo 'export PATH=$PATH:$HOME/.composer/vendor/bin' >> /etc/profile.d/composer.sh

# Create a platform user
# Put whatever you want into this folder, maybe .ssh credentials, drush, etc
ADD home/platform /home/platform
RUN /usr/bin/yum install -y openssl zsh git sudo vim && \
    adduser -d /home/platform -M -u 1000 -G wheel -s /usr/bin/zsh -p "`echo "platform" | openssl passwd -1 -stdin`" -c "development login" platform && \
    /usr/bin/ssh-keygen -b 2048 -t rsa -f /home/platform/.ssh/id_rsa -q -N "" && \
    chown -R platform:platform /home/platform && \
    echo "platform        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/platform

# Everything else is run as the platform user
USER platform

# Install DRUSH, which is a requiremnt for platform
RUN composer global require drush/drush:dev-master

# Install platform.sh cli
RUN composer global require "commerceguys/platform-cli=1.*"

# user oh-my-zsh
#RUN curl -L https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

ENV HOME /home/platform
ENV PATH $HOME/bin:${HOME}/.composer/vendor/bin:$HOME/.gem/ruby/2.1.0/bin:/usr/local/bin:$PATH
CMD /bin/zsh