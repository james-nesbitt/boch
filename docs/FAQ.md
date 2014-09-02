= QUICK FAQ =

1. Why can't I start my container:

  - did you build first
  - did you run any funky customizations that failed the build?
       - check that the image was created
       - check the build output for an error

2. I started my container but I don't see it?

  - are you expecting a prompt or output, because the default conf
    doesn't provide any

3. I used the shell command, but my changes disappear

  - shell is meant to provide a temporary container based on the image
       - you can try --persistant to have the container stay
  - shell gives you a new container, not the same container
    as you have in start.
  - shell is meant as a tools to debug the
    container, or to make changes that are then commited to the
    image.

4. I don't like the file layout, how do I change it?

  - The top of the control script has a number of bash variables pointing to the various elements.  You could change those
  - if you don't like the source/www system, then feel free to remove it, but make sure to adjust the volume mounts, and nginx configuration as well.
