= TODO LIST =

== DOCUMENTATION ==

* documentation can now go into the various folders, as all scripts are now looking for executable files only.

1. document the help system
2. rewrite the command documentation
3. document the flow system
4. explain the hooks system

== SETTINGS ==

1. make the mount system more abstract : abstraction is there, but the loading of build paths is hardcoded into the build command

== LIBRARIES ==

The following are ideas for libraries that should be started

1. boot2docker : to implement hooks that integrate better with boot2ocker
2. drush : drush integration (requires some way to connect into the containers,
     or you have to be able to

== COMMANDS ==

The following commands would be a good idea

1. ssh : ssh into the container - this has certain container requiredments (sshd and a user?)


== FLOW ==

1. make a way to determine if a flow exists
2. make a way to list all of the flows
3. make some interesting flows, that might make this system worth using  :P
    I actually started the feature flow, so it could be usefull soon

= BUG LIST =

It's actually pretty clean right now, the only problem is that it suffers
overusage of hooks and abstraction (which was kind of the goal)
