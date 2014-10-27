= README =

This is a docker image, that extends wwwserver-cnpm, with developer tools

Basically it adds

- some php/xdebug tools;
- ruby, rubygems and rubygem-bundler, so that SASS can easily be used (ruby 2.0)
- and changes some php/mysql settings to allow more memory use.
- a "developer" user, which can be used for ssh, other stuff (with passwordless sudo privileges)

@NOTE only the dev home folder is added, the rest are added as files