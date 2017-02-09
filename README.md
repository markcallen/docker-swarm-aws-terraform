# Docker Swarm on AWS using Terraform

## Setup

Install [docker](https://www.docker.com/products/docker)

Install [packer](https://www.packer.io/downloads.html)

Install [terraform](https://www.terraform.io/downloads.html)

Clone this repo
````
git clone https://github.com/markcallen/docker-swarm-aws-terraform/
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
Creating a AMI with docker installed will speed up the creation of the docker
swarm as all the nodes will be exactly the same.
