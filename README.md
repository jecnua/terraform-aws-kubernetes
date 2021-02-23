# Terraform module for kubernetes on AWS

[![Actions Status](https://github.com/jecnua/terraform-aws-kubernetes/workflows/Tests/badge.svg)](https://github.com/jecnua/terraform-aws-kubernetes/actions)
![https://www.terraform.io/](https://img.shields.io/badge/terraform-v0.14.x-blue.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![](https://img.shields.io/maintenance/yes/2021.svg)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/jecnua/terraform-aws-kubernetes.svg)](http://isitmaintained.com/project/jecnua/terraform-aws-kubernetes "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/jecnua/terraform-aws-kubernetes.svg)](http://isitmaintained.com/project/jecnua/terraform-aws-kubernetes "Percentage of issues still open")

This repo contains a set of modules to install a kubernetes cluster in your own AWS environment.
More information on each module can be found here:

- [controller module](modules/controllers/): Spin up a single master to be used as control plane
- [cri module](modules/cri/): Modules to choose which container engine to use
    - [containerd module](modules/controllers/containerd)
    - [cri-o module](modules/controllers/cri-o)
    - [docker module](modules/controllers/docker)
- [nodes module](modules/nodes/): Spin up a set of nodes to act as nodes for the cluster

[Module maintainers](MAINTAINERS.md)

This module is not intended to be used for production workload.

At the moment I wanted to avid dependencies to external tools like ansible, so the installation happens in bash with
cloud-init. This means some architectural choices are defined in there, and they can't be modified.

Obviously this can be fixed, just fork and PR into this :)

## Supported terraform versions

*NOTE*: It only supports Terraform 0.14.x onward

For older Terraform version please use:

- For 0.11 the tag _v0.11.x-last-supported-code_
- For 0.12 the tag _v0.12.x-last-supported-code_
- For 0.13 the tag _v0.13.x-last-supported-code_
