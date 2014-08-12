#
# Multiline runs are used to minimize RUN transactions to keep the cache
# shorter for this basebox.  There is no need to overdo the caching here.
#
FROM            wwwserver-cnpm-dev
MAINTAINER      james.nesbitt@wunderkraut.com

# Include RVM and bundler for compass/sass access
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1
