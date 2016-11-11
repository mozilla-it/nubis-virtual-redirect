# virtual-redirect Nubis deployment repository

## Objective

This deployment repository defines how the virtual-redirect infrastructure is
setup in AWS. You'll find a nubis directory which houses Packer, Puppet and
Terraform configuration files.

## How to use this

When you commit a change to the master branch in this repository, it will
trigger a job on the Jenkins server to build a new go through the Nubis build
process, perform any provisioning and apply the Terraform configuration.
