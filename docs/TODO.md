= TODO LIST =

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

1. boot2docker (STARTED) : to implement hooks that integrate better with boot2ocker
2. drush : drush integration (requires some way to connect into the containers,
     or you have to be able to

== UTILITIES ==

1. The lists concept has stub function to remove an item from a list, and to update an existing item,
2. The lists concept should check for existing items

== SETTINGS ==


== HELP ==

* It would be nice to have a function to pull help information from comments in a file, this would make
  documenting API and functions much easier

== HOOKS ==

1. the hooks_execute takes parameters like this: hooke_execute "{hook} --action "{action}" --state "{state}"
   probably it would be better like this : hooke_execute --action "{action}" --state "{state}" "{hook}"

== DOCKER ==

1. The docker API has no natural way to output help information (It would be necessary to repeat all comments from the api file)
   (It would be cool to pull it from the comments in the API file)

== COMMANDS ==

The following commands would be a good idea:

1. export/import : docker has this functionality, why don't we?
2. source copy : branching source will be usefull for some future flow
      concepts, so that different containers are using different source
      folders, and won't conflict

== FLOW ==

1. make some interesting flows, that might make this system worth using  :P
    I actually started the feature flow, so it could be useful soon

= BUG LIST =

It's actually pretty clean right now, the only problem is that it suffers
overusage of hooks and abstraction (which was kind of the goal) which make
it confusing to trace errors.

There are a lot of commands/hooks that don't do safety checks on params

== SECURITY ==

There is no security review:

- the list management tools (_utilities) execute some var code that could be unsafe
- the hook manager executes various functions using eval()
- there are two functions in the docker library that use eval() to apply greps

* No code executes with any escalated permission;
* Code could run in elevated permissions inside a container.
