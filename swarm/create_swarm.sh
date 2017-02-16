#!/bin/bash
#
#

set -e

if [ "$*" == "" ]; then
    echo "Need an arguement of plan, apply or destory"
    exit 1
fi

if ! docker history -q hashicorp/terraform:light >/dev/null 2>&1; then
 docker pull hashicorp/terraform:light
fi

if ! docker history -q mesosphere/aws-cli >/dev/null 2>&1; then
  docker pull mesosphere/aws-cli
fi

: ${AWS_ACCESS_KEY_ID:?"Need to set AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY:?"Need to set AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION:?"Need to set AWS_DEFAULT_REGION"}
: ${AWS_SSH_KEY_ID:?"Need to set AWS_SSH_KEY_ID"}
: ${AWS_SSH_KEY:?"Need to set AWS_SSH_KEY"}

cp ${AWS_SSH_KEY} .
AWS_SSH_KEY=/terraform/`basename ${AWS_SSH_KEY}`

AWS="docker run --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION -t $(tty &>/dev/null && echo "-i") mesosphere/aws-cli"

DOCKER_AMI=$($AWS ec2 describe-images --owners self --filters "Name=name,Values=docker*" --query 'Images[*].[ImageId,Name,CreationDate]' --output text | sort -k 4 -r | head -1 | awk '{print $1'})

TERRAFORM="docker run --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION -v $PWD:/terraform -i -t hashicorp/terraform:light"

$TERRAFORM $1 -var aws_region=${AWS_DEFAULT_REGION} \
              -var 'amis={ "'${AWS_DEFAULT_REGION}'" = "'${DOCKER_AMI}'" }' \
              -var ssh_key_name=${AWS_SSH_KEY_ID} \
              -var ssh_key_filename=${AWS_SSH_KEY} \
              -state=/terraform/terraform.tfstate /terraform

rm `basename ${AWS_SSH_KEY}`
