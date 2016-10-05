#!/bin/bash
. ./common/constants.sh

read -p "This will erase all contents from AWS EC2 volume ${EXTERNAL_VOLUME_AWS_VOLUME_ID}. Format? [Y/n]" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo "Creating instance"
# This script will set the ip_address and instance_id variables
. ./aws_ec2/launch_instance.sh ${SSH_KEY_PATH} "on-demand" "t2.micro" /dev/null

echo "Formatting remote ${EXTERNAL_VOLUME_DEVICE_NAME}"
printf "sudo mkfs -t ext4 ${EXTERNAL_VOLUME_DEVICE_NAME}" | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}

aws ec2 terminate-instances --instance-ids "$instance_id" --output text --query 'TerminatingInstances[*].CurrentState.Name'