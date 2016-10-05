#!/bin/bash
. ./common/constants.sh

SESSION_ID="201609040550"
ip_address="192.168.2.2"

echo "Preparing remote volume"

cat common/constants.sh common/mount_external_volume.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/prepare_root_contents_folder.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/install_dependencies.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/docker_run_service.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/docker_purge_all_containers.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/docker_run_container.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}

echo "Train agent (resume session ${SESSION_ID})"
echo "nohup bash -c \"${DOCKER_RUNNER} exec ${DOCKER_CONTAINER_NAME} \
                        bash -c 'cd ${CONTAINER_PATH_AGENT_TRAINER}; \
                                 source venv/bin/activate; \
                                 python -m agent train-resume --resultspath ${CONTAINER_PATH_TRAIN_RESULTS} -s ${SESSION_ID}'\" \
        &> ${HOST_PATH_NOHUP_LOG_FILE} &"  | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}

echo "Following progress of train"
ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address} tail -f ${HOST_PATH_NOHUP_LOG_FILE}


