#!/bin/bash
#
# Create an instance only to SSH; useful to verify the external volume for debugging reasons
#

. ./common/constants.sh

# This script will set the ip_address and instance_id variables
. ./aws_ec2/launch_instance.sh ${SSH_KEY_PATH} "on-demand" "t2.micro" /dev/null

echo "Preparing remote volume"
cat common/constants.sh common/mount_external_volume.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
cat common/constants.sh common/prepare_root_contents_folder.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
#cat common/constants.sh common/install_dependencies.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
#cat common/constants.sh common/run_docker.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}

ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}

aws ec2 terminate-instances --instance-ids "$instance_id" --output text --query 'TerminatingInstances[*].CurrentState.Name'