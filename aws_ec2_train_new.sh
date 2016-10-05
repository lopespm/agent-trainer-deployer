#!/bin/bash
. ./common/constants.sh

YOUR_OUTRUN_ROMS_PATH="/local/folder/of/your/outrun_roms" # You will need to provide your OutRun game roms; these will be copied to agent-trainer's roms/ folder below

# This script will set the ip_address and instance_id variables
. ./aws_ec2/launch_instance.sh ${SSH_KEY_PATH} "spot" "g2.2xlarge" "0.13"

echo "Preparing remote volume"

cat common/constants.sh common/mount_external_volume.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/prepare_root_contents_folder.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/install_dependencies.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/fetch_source_repositories.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/docker_run_service.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/docker_build_image.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/docker_purge_all_containers.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/docker_run_container.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/docker_prepare_container_shared_contents.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}

# Copy the roms to agent trainer
scp -i ${SSH_KEY_PATH} ${YOUR_OUTRUN_ROMS_PATH}/* ${HOST_USERNAME}@${ip_address}:${HOST_PATH_AGENT_TRAINER}/roms

echo "Train agent (new session)"
echo "nohup bash -c \"${DOCKER_RUNNER} exec ${DOCKER_CONTAINER_NAME} \
                        bash -c 'cd ${CONTAINER_PATH_AGENT_TRAINER}; \
                                 source venv/bin/activate; \
                                 python -m agent train-new --ec2spot --resultspath ${CONTAINER_PATH_TRAIN_RESULTS}'; \
                      sudo shutdown -h now\" \
        &> ${HOST_PATH_NOHUP_LOG_FILE} &"  | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}

echo "Following progress of train"
ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address} tail -f ${HOST_PATH_NOHUP_LOG_FILE}


