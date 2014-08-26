= DOCKER LIBRARY =

The docker library is a set of lower level routines, that can be used
to actually run docker commands, but with some level of abstraction
for implementation.
This library was the first part of the application built, but it was
quickly clear that a level of project configuration was required, so
this library was built upon.

* this library is meant to not be aware of any of the system configurations.
