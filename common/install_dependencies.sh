sudo yum update -y
sudo yum install -y git
sudo yum install -y docker

if [ "$USE_GPU" = true ] ; then
    sudo yum groupinstall -y "Development tools"
    sudo yum install -y kernel-devel-`uname -r`

    # install the driver
    wget http://us.download.nvidia.com/XFree86/Linux-x86_64/367.44/NVIDIA-Linux-x86_64-367.44.run
    sudo /bin/bash NVIDIA-Linux-x86_64-367.44.run  --silent

    # Install nvidia-docker and nvidia-docker-plugin
    wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.0-rc.3/nvidia-docker_1.0.0.rc.3_amd64.tar.xz
    sudo tar --strip-components=1 -C /usr/bin -xvf /tmp/nvidia-docker*.tar.xz && rm /tmp/nvidia-docker*.tar.xz
fi