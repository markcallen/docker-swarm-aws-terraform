#!/bin/bash
#
#

set -e

if [ "$*" == "" ]; then
    echo "Need an arguement of plan, apply or destory"
    exit 1
fi

path_to_terraform=$(which terraform)
if [ ! -x "$path_to_terraform" ] ; then
   echo "Can't find terraform, check that its in your path"
   exit 1;
fi

path_to_aws=$(which aws)
if [ ! -x "$path_to_aws" ] ; then
   echo "Can't find aws cli, check that its in your path"
   exit 1;
fi

: ${AWS_ACCESS_KEY_ID:?"Need to set AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY:?"Need to set AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION:?"Need to set AWS_DEFAULT_REGION"}
: ${AWS_SSH_KEY_ID:?"Need to set AWS_SSH_KEY_ID"}
: ${AWS_SSH_KEY:?"Need to set AWS_SSH_KEY"}

if [ -d ../flocker-openssl ]; then
  cd ../flocker-openssl && git pull && cd ../mgmt
else
  cd .. && git clone https://github.com/ClusterHQ/flocker-openssl && cd mgmt
fi

cat > agent.yml <<EOL
"version": 1
"control-service":
   "hostname": "fcontrol.a.databaseb.in"
   "port": 4524

# The dataset key below selects and configures a dataset backend (see below: aws/openstack/etc).
# All nodes will be configured to use only one backend

dataset:
   backend: "aws"
   region: "${AWS_DEFAULT_REGION}"
   zone: "${AWS_DEFAULT_REGION}a"
   access_key_id: "${AWS_ACCESS_KEY_ID}"
   secret_access_key: "${AWS_SECRET_ACCESS_KEY}"
EOL

if [ $1 == "apply1" ]; then
  OLDPATH=$PATH
  # Fix the problem with readlink -f not working on osx and needing to using coreutils version instead
  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
  # TODO: create -n dynamically 
  cd ../flocker-openssl && ./generate_flocker_certs.sh new --force -d=fcontrol.a.databaseb.in -c=a.databasebin -n=swarm-manager-0,swarm-manager-1,swarm-manager-2,swarm-node-0,swarm-node-1,swarm-node-2 && cd ../mgmt
  PATH=$OLDPATH
fi

USEAST1_AMI=$(aws ec2 describe-images --owners self --filters "Name=root-device-type,Values=ebs,Name=virtualization-type,Values=hvm" --query 'Images[*].[ImageId,Name,CreationDate]' --output text | grep docker-swarm-flocker | sort -k 3 -r | head -1 | awk '{print $1'})

terraform $1 -var aws_region=${AWS_DEFAULT_REGION} \
                -var 'amis={ us-east-1 = "'${USEAST1_AMI}'" }' \
                -var ssh_key_name=${AWS_SSH_KEY_ID} \
                -var ssh_key_filename=${AWS_SSH_KEY}

