# Amazon ECS Terraform module

This module allows the creation of all resources needed to run and monitor an
ECS service with high availability, logging and load balancing capabilities

Here is a (not comprehensive) list of resources created:
- A VPC and Internet Gateway
- A Public Subnet that is created in two different availability zones
- An Auto Scaling Group to create the EC2 instances that will host the ECS instances
- An Application Load Balancer
- An ECS cluster and the related ECS service with Cloudwatch logging enabled

## Usage

To test and check that everything works fine I added a module that will make use
of the main `ecs` module to create two services into two different environments
using two different methods:
- A `hello world` service that have the parameters set with hard coded values
- A `lb-test` service that uses input variables from a vars file (`terraform.tfvars`) 

The usage is pretty standard, we just need to have user credentials (set with
environment variables or configuration file) and issue the following commands:
```
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

At the end of the run you will be presented with the availability zones where
the instances are running and the endpoint to access each web service (as
output variables)

Note: You have the option to upload your SSH Public key to the EC2 instances by supplying
it as a `id_rsa.pub` file to be put in the root level of this repository,
that is, the same level as the [`ecs.tf`](ecs.tf) file.

## Improvements

<del>Next possible improvement is to split the big `ecs` module into small submodules to
make it more manageable, improve code reuse and allow the use of individual modules
when appropriate.</del> Done!

Next improvement, in progress, it is to move the EC2 instances into a private subnet,
allow them to connect to the internet by means of an added NAT gateway and let only
the Load Balancer publicly exposed to increase the security of the cluster.
