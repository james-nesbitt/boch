= Boot 2 Docker library =

This library attempts to integrate the boot2docker interactions into the
toolset.

The primary requirements are:

1. Add project and user mounts to the b2d VM, so that they can be mounted in containers
2. ReMap container mounts to point to the VM path, instead of the host path.

Currently implemented:
1. When the init flow is run, the project root, and user ${HOME} path are mounted in the b2d VM at the /media path
2. When containers are started, the mount paths are remapped where possible to point to the VM paths that match the mount

@NOTE VBoxManage is used for mounts.  It gives us the ability to add and remove mounts, BUT IT DOES NOT GIVE US A WAY TO LIST MOUNTS TO KNOW WHAT WE HAVE ALREADY MOUNTED.
For now we just remount everything and accept VBoxManage errors, but we will likely have to add some kind of static list of paths mounted.

@TODO this library is really in an infant state.  It can do the mapping but it will cause plenty of errors all over the place.
