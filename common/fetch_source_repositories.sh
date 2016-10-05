# Pre-create the training results folder
mkdir -p ${HOST_PATH_TRAIN_RESULTS}

# Clone repositories
git clone https://github.com/lopespm/agent-trainer.git ${HOST_PATH_AGENT_TRAINER}
git clone https://github.com/lopespm/cannonball.git ${HOST_PATH_GAME_EMULATOR_SOURCE}
git clone https://github.com/lopespm/agent-trainer-docker.git ${HOST_PATH_DOCKER_IMAGE_SOURCE}