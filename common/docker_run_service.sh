printf "DAEMON_MAXFILES=1048576\nOPTIONS=\"--default-ulimit nofile=1024:4096 -g ${HOST_PATH_DOCKER_ROOT}\"\n" | sudo tee /etc/sysconfig/docker
sudo service docker start
sudo groupadd docker
sudo usermod -a -G docker ${HOST_USERNAME}