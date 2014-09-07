= QUICK FAQ =

1. Why can't I start my container:

  - did you build first
  - did you run any funky customizations that failed the build?
       - check that the image was created
       - check the build output for an error

2. I started my container but I don't see it?

  - are you expecting a prompt or output, because the default conf
    doesn't provide any.  It is expected that a started container
    will silently sit in the background doing it's job.

3. I used the shell command, but my changes disappear

  - shell is meant to provide a temporary container based on the image
       - you can try --persistant to have the container stay
  - shell gives you a new container, not the same container
    as you have in start.
  - shell is meant as a tools to debug the
    container, or to make changes that are then commited to the
    image.

4. I don't like the file layout, how do I change it?

  - The top of the control script has a number of bash variables
    pointing to the various elements.  You could change those.
  - Feel free to re-arrange the architecture as desired.  It should be
    enough to drop large elements, althought some libraries may have
    features that break with extreme changes.

5. How do I start using the toolset

   Check out the QUICKSTART doc.
