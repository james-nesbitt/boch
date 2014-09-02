= TODO LIST =

Goals and bonus things in the project

== DOCUMENTATION ==

* this toolset suffers from a lack of documentation, both as lots of --help features;
* documentation can now go into the various folders, as all scripts are now looking for executable files only.

== HELP ==

1. The help system is usefull, but it is not very legible to new users.  It
   puts out too much garbage, and doesn't do enough helping.
   It had great abstraction, but could use an implementation refactor in
   control and flow implementations.

== LIBRARIES ==

The following are ideas for libraries that should be started

1. boot2docker : to implement hooks that integrate better with boot2ocker
2. drush : drush integration (requires some way to connect into the containers,
     or you have to be able to
3. git / git-flow : exactly

== COMMANDS ==

The following commands would be a good idea:

1. export/import : docker has this functionality, why don't we?
2. source copy : branching source will be usefull for some future flow
      concepts, so that different containers are using different source
      folders, and won't conflict

== FLOW ==

1. make some interesting flows, that might make this system worth using  :P
    I actually started the feature flow, so it could be usefull soon

= BUG LIST =

It's actually pretty clean right now, the only problem is that it suffers
overusage of hooks and abstraction (which was kind of the goal) which make
it confusing to trace errors.

There are a lot of commands/hooks that don't do safety checks on params,

== SECURITY ==

There is no security review:

- the list management tools (_utilities) execute some var code that could be unsafe
- the hook manager executes various functions using eval()
- there are two functions in the docker library that use eval() to apply greps to
    docker output;
