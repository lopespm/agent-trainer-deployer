#!/bin/bash
. ./common/constants.sh

SESSION_ID="201609171218"
RETRIEVED_TRAINING_RESULTS_PATH="/local/folder/where/results/will/be/downloaded"
CREATE_NEW_INSTANCE=false

if [ "${CREATE_NEW_INSTANCE}" = true ] ; then
    echo "Creating new instance"
    # This script will set the ip_address and instance_id variables
    . ./aws_ec2/launch_instance.sh ${SSH_KEY_PATH} "on-demand" "t2.micro" /dev/null

    echo "Preparing remote volume"
    cat common/constants.sh common/mount_external_volume.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
    cat common/constants.sh common/prepare_root_contents_folder.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
else
    ip_address="52.197.57.175"
    echo "Will retrieve results from existing instance in ${ip_address}"
fi


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

if [ "$CREATE_NEW_INSTANCE" = true ] ; then
    aws ec2 terminate-instances --instance-ids "$instance_id" --output text --query 'TerminatingInstances[*].CurrentState.Name'
fi