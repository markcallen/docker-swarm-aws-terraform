# Docker Swarm on AWS using Terraform

## Setup

Install [docker](https://www.docker.com/products/docker)

Install [packer](https://www.packer.io/downloads.html)

Install [terraform](https://www.terraform.io/downloads.html)

Create a new user in IAM with Programmatic Access, Attach the following
policies AmazonVPCFullAccess, AmazonEC2FullAccess.  Saving the Access Key ID
and Secret Access Key.

Set environment variables for AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and
AWS_DEFAULT_REGION.

````
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=ca-central-1
````

Create a new EC2 keypair and download the pem file.

Set environment variables for AWS_SSH_KEY_ID and AWS_SSH_KEY

````
export AWS_SSH_KEY_ID=docker
export AWS_SSH_KEY=docker.pem
````

Clone this repo
````
git clone https://github.com/markcallen/docker-swarm-aws-terraform.git
````

## Alternatives

If you don't want to install packer or terraform locally you can use docker
images with them:

terraform
````
TERRAFORM="docker run -rm -v $PWD:/terraform -i -t hashicorp/terraform:light"

$TERRAFORM run -state=/terraform/terraform.tfstate /terraform
````

packer
````
PACKER="docker run -rm -v $PWD:/packer -i -t hashicorp/packer:light"

$PACKER build /packer/docker-gce.json
````

## Building a AWS AMI with docker
Creating a AMI with docker preinstalled will speed up the creation of the docker
swarm as all the nodes will be exactly the same.

Create a VPC
````
cd packer
terraform plan
terraform apply
````

Get the values of aws_vpc_id, aws_subnet_id and aws_security_group_id from

````
terraform show
````

Create the AMI
````
packer -var aws_vpc_id=... \
       -var aws_subnet_id=... \
       -var aws_security_group_id=... \
       build docker-aws.json
````

Teardown the VPC
````
terraform destroy
````

Get the AMI name
````
aws ec2 describe-images --owners self --query 'Images[*].[ImageId,Name,CreationDate]' --output text
````

## Creating the Swarm
Use terraform to create several masters and slaves.

````
cd swarm
terraform plan
terraform apply
````



## License & Authors
- Author:: Mark Allen (mark@markcallen.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
