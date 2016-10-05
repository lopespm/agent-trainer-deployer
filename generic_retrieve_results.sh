#!/bin/bash
. ./common/constants.sh

SESSION_ID="201609040550"
RETRIEVED_TRAINING_RESULTS_PATH="/local/folder/where/results/will/be/downloaded"

ip_address="192.168.2.2"

echo "Retrieving session ${SESSION_ID} training results from ${ip_address}"

mkdir -p "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}"
mkdir -p "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}/metrics-q-network"

scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_TRAIN_RESULTS}/${SESSION_ID}/checkpoint" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}"
scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_TRAIN_RESULTS}/${SESSION_ID}/episode_number.pickle" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}"
scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_TRAIN_RESULTS}/${SESSION_ID}/global_step.pickle" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}"
scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_TRAIN_RESULTS}/${SESSION_ID}/q_network.data" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}"
scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_TRAIN_RESULTS}/${SESSION_ID}/q_network.data.meta" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}"
scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_TRAIN_RESULTS}/${SESSION_ID}/metrics_in_train.data" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}"
scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_TRAIN_RESULTS}/${SESSION_ID}/metrics_trained_play.data" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}"
scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_TRAIN_RESULTS}/${SESSION_ID}/metrics-q-network/*" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}/metrics-q-network"
#scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_TRAIN_RESULTS}/${SESSION_ID}/replay-memories/*" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}/replay-memories"
scp -i ${SSH_KEY_PATH} -r ec2-user@${ip_address}:"${HOST_PATH_NOHUP_LOG_FILE}" "${RETRIEVED_TRAINING_RESULTS_PATH}/${SESSION_ID}"