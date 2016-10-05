#
# Game Emulator (Cannonball) setup
#

# Build the Cannonball (outrun game emulator) and copy the resulting lib to agent_trainer
docker exec ${DOCKER_CONTAINER_NAME} bash -c "mkdir ${CONTAINER_PATH_GAME_EMULATOR_SOURCE}/build"
docker exec ${DOCKER_CONTAINER_NAME} bash -c "cd ${CONTAINER_PATH_GAME_EMULATOR_SOURCE}/build; cmake -G 'Unix Makefiles' -DTARGET:STRING=sdl2 ../cmake"
docker exec ${DOCKER_CONTAINER_NAME} bash -c "cd ${CONTAINER_PATH_GAME_EMULATOR_SOURCE}/build; make"
docker exec ${DOCKER_CONTAINER_NAME} bash -c "cp ${CONTAINER_PATH_GAME_EMULATOR_SOURCE}/build/libcannonball.so ${CONTAINER_PATH_AGENT_TRAINER}/lib/libcannonball.so"

#
# Agent trainer setup
#

# Setup virtualenv
docker exec ${DOCKER_CONTAINER_NAME} bash -c "pip install virtualenv"
docker exec ${DOCKER_CONTAINER_NAME} bash -c "cd ${CONTAINER_PATH_AGENT_TRAINER}; virtualenv -p python2.7 venv"

# Install agent trainer dependencies
docker exec ${DOCKER_CONTAINER_NAME} bash -c "cd ${CONTAINER_PATH_AGENT_TRAINER}; source venv/bin/activate; USE_GPU=${USE_GPU} make init"
