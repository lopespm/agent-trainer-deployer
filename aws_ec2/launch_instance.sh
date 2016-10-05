# These are provided when executing the script
SSH_KEY_PATH=$1
EC2_PRODUCT_TYPE=$2 # Accepted types: on-demand | spot 
INSTANCE_TYPE=$3
SPOT_PRICE_LIMIT=$4

EC2_PRODUCT_TYPE_ON_DEMAND="on-demand"
EC2_PRODUCT_TYPE_SPOT="spot"

KEY_PAIR_NAME="your-key-pair-name"

IMAGE_ID="ami-xxxxxxxx"
SECURITY_GROUP="sg-xxxxxxxx"
SUBNET_ID="subnet-xxxxxxxx"

# Check prerequisites
command -v aws >/dev/null 2>&1 || { echo "To execute this script you need AWS CLI: http://docs.aws.amazon.com/cli/latest/userguide/installing.html" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required to run this script. More info here: https://stedolan.github.io/jq/download/" >&2; exit 1; }

if [ "$EC2_PRODUCT_TYPE" = "$EC2_PRODUCT_TYPE_ON_DEMAND" ]; then
    instance_id=$(aws ec2 run-instances \
        --image-id ${IMAGE_ID} \
        --count 1 \
        --instance-type ${INSTANCE_TYPE} \
        --key-name ${KEY_PAIR_NAME} \
        --security-group-ids ${SECURITY_GROUP} \
        --subnet-id ${SUBNET_ID} \
        --instance-initiated-shutdown-behavior terminate \
        --output text --query 'Instances[*].InstanceId')
    echo "Created instance with id $instance_id"
elif [ "$EC2_PRODUCT_TYPE" = "$EC2_PRODUCT_TYPE_SPOT" ]; then
    spot_request_id=$(aws ec2 request-spot-instances \
    --spot-price ${SPOT_PRICE_LIMIT} \
    --instance-count 1 \
    --launch-specification \
        "{ \
            \"ImageId\":\"${IMAGE_ID}\", \
            \"InstanceType\":\"${INSTANCE_TYPE}\", \
            \"KeyName\":\"${KEY_PAIR_NAME}\", \
            \"SecurityGroupIds\": [\"${SECURITY_GROUP}\"], \
            \"SubnetId\": \"${SUBNET_ID}\" \
        }" | jq --raw-output '.SpotInstanceRequests[0].SpotInstanceRequestId')
    echo "Spot request id: $spot_request_id"

    echo "Waiting for spot request to be fulfilled"
    aws ec2 wait spot-instance-request-fulfilled --spot-instance-request-ids ${spot_request_id}
    instance_id=$(aws ec2 describe-spot-instance-requests --spot-instance-request-ids "$spot_request_id" | jq --raw-output '.SpotInstanceRequests[0].InstanceId' )
    echo "$spot_request_id fulfilled: instance was launched with instance id: $instance_id"
else
    echo "Unexpected EC2_PRODUCT_TYPE ${EC2_PRODUCT_TYPE}. Accepted types: ${EC2_PRODUCT_TYPE_ON_DEMAND} | ${EC2_PRODUCT_TYPE_SPOT}"
    exit 1
fi

echo "Waiting for instance to leave 'pending' state"
aws ec2 wait instance-running --instance-ids "$instance_id"
echo "$instance_id is now running"

ip_address=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ip_address=$ip_address

echo "Waiting for external volume to become available"
aws ec2 wait volume-available --volume-ids "$EXTERNAL_VOLUME_AWS_VOLUME_ID"
echo "Attaching external volume"
aws ec2 attach-volume --volume-id ${EXTERNAL_VOLUME_AWS_VOLUME_ID} --instance-id $instance_id --device ${EXTERNAL_VOLUME_DEVICE_NAME} > /dev/null
echo "Attached external volume"

echo "Verifying fingerprints"
aws ec2 get-console-output --instance-id ${instance_id} --output text |
  perl -ne 'print if /BEGIN SSH .* FINGERPRINTS/../END SSH .* FINGERPRINTS/'

echo "-- SSH by:"
echo "-- ssh -i ${SSH_KEY_PATH} ec2-user@${ip_address} --"
echo "--"

echo "Waiting until SSH is available for sending commands"
ssh_exit_status=255
while [[ $ssh_exit_status -eq 255 ]];do
    sleep 1; echo -n '.'
    ssh -i ${SSH_KEY_PATH} ec2-user@${ip_address} -q -o "StrictHostKeyChecking no" echo "SSH now available"
    ssh_exit_status=$?
done