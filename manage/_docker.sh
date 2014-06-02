#!/bin/sh

#
# Build a new docker image from the Dockerfile
docker_build() {
  docker build --tag="${Docker_image}" ${path_conf}
  echo "Docker build run. '${Docker_image}' image created"
}
# Destroy any build images
docker_destroy()
{
  docker rmi $Docker_image
}
#
# Start a built box
#
# @todo : check for built container ( docker ps --all | grep ${Docker_container}
# @todo : check for running container ( docker ps | grep ${Docker_container}
# @todo : check for stopped container
docker_run()
{
  #echo "docker run -h ${Machine_hostname} --name ${Docker_container} -d -t ${Machine_volumes} ${Docker_image} /usr/bin/supervisord -n"
  Docker_containerID="$(docker run --hostname=${Machine_hostname} -t -d ${Machine_volumes} ${Docker_image} /usr/bin/supervisord --conf /etc/supervisord.conf --nodaemon)"
  echo "${Docker_containerID}" > ./_containerid
  echo "MANAGE=> Started ${Docker_image} as container:${Docker_container} ID:${Docker_containerID}"
}
#
# start a shell version of a container
#
# @todo : merge with docker_run as a flag
docker_shell()
{
  docker run --hostname=${Machine_hostname} --name=${Docker_container} --user="developer" --env HOME=/home/developer -t -i -P ${Docker_rm} ${Machine_volumes} ${Docker_image} ${1:-"/bin/zsh"}
}

docker_attach()
{
  docker attach ${Docker_container}
}

#
# Stop a running box
docker_stop()
{
  docker kill $Docker_containerID
}

docker_rm()
{
  docker rm $Docker_container
}


docker_inspect()
{
  docker inspect $Docker_container
}