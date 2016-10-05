if [ "$USE_GPU" = true ] ; then
    sudo -b nohup nvidia-docker-plugin > /tmp/nvidia-docker.log
fi

${DOCKER_RUNNER} run -d --name ${DOCKER_CONTAINER_NAME} -v ${HOST_PATH_DOCKER_SHARE}:${CONTAINER_PATH_DOCKER_SHARE} ${DOCKER_IMAGE_NAME}