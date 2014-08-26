= TODO LIST =

== DOCUMENTATION ==

* this toolset suffers from a lack of documentation, buth as lots of --help features;
* documentation can now go into the various folders, as all scripts are now looking for executable files only.

1. document the help system;
2. document the flow system;
3. explain the hooks system.

== LIBRARIES ==

1. autorun a library_init method after loading the library?

The following are ideas for libraries that should be started

1. boot2docker : to implement hooks that integrate better with boot2ocker
2. drush : drush integration (requires some way to connect into the containers,
     or you have to be able to

== UTILITIES ==

1. a "debug_reset" function would be nice, to set the debug level back to an unset value after running debug_set_level

== SETTINGS ==


== HELP ==


== DOCKER ==

1. The docker API has no natural way to output help information (It would be necessary to repeat all comments from the api file)

== COMMANDS ==

1. commands don't output very usefull output.  We likely need a messaging system, similar to debug

== FLOW ==

1. make some interesting flows, that might make this system worth using  :P
    I actually started the feature flow, so it could be usefull soon

= BUG LIST =

It's actually pretty clean right now, the only problem is that it suffers
overusage of hooks and abstraction (which was kind of the goal) which make
it confusing to trace errors.

There are a lot of commands/hooks that don't do safety checks on params

1. settings are loaded twice - once when the library is loaded, but again on a settings hook (040)

== SECURITY ==

There is no security review:

- the list management tools (_utilities) execute some var code that could be unsafe
- the hook manager executes various functions using eval()
- there are two functions in the docker library that use eval() to apply greps

* No code executes with any escalated permission;
* Code could run in elevated permissions inside a container.
