= Example Library =

== Core File ==

The core file must be an executable with the same name as the folder (the name of the library.)  This file can container an init function, run when the library is loaded.
The file is meant to hold functions used in the library.  Sometimes the functions are kept in an API include, as in the case of the docker library.

== Settings File ==

The settings file is loaded before the library handler, and should contain various settings and setting overrides used by the project.

== Help Handler ==

The help handler, if is exists, tells the help library that this library gives help information.
The help library assumes that any library with a help include can handle help topics of the form mylibrary:${topic}.

== Hooks example ==

The example library shows how you can implement a hook, by giving an example hook

== Other optional components ==

=== other libraries ===

A library can container a /libraries folder itself, which can make any number of additional libraries available to the system.  Naturally a library must be loaded, before it's own libraries are available to be loaded.

=== commands ===

You can implement additional commands in your library, by putting them into a /commands folder.  This is called library component functionality, where implementations of a library can be found in a specfic folder in any other enabled library.
