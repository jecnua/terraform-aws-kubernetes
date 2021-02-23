# Kubernetes module - Nodes

![](https://img.shields.io/badge/kubernetes-v1.20.x-green.svg)
![](https://img.shields.io/badge/ubuntu-20.04-blue.svg)

This module will create a new kubernetes cluster inside your VPC.

# Parameters

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| null | n/a |
| random | n/a |
| template | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) |
| [aws_autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) |
| [aws_autoscaling_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_notification) |
| [aws_elb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb) |
| [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) |
| [aws_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) |
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tags\_as\_map | A map of tags and values in the same format as other resources accept. This will be converted into the non-standard format that the aws\_autoscaling\_group requires. | `map(string)` | `{}` | no |
| ami\_id\_worker | The id of the AMI to use for the workers. If empty, the latest ubuntu will be used. | `string` | `""` | no |
| ami\_name\_filter\_regex | Regex to find the ami to use | `string` | `"ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"` | no |
| ami\_name\_regex | The name regex | `string` | `"^.*"` | no |
| ami\_owner | ID of the owner of the ami (example 099720109477 for Canonical) | `string` | `"099720109477"` | no |
| availability\_zone | The availability zone to use. Be careful, r4.2xlarge are still not available in C for example | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1b",<br>  "eu-west-1c"<br>]</pre> | no |
| block\_device\_mappings | The EC2 instance block device configuration. Takes the following keys: `delete_on_termination`, `volume_type`, `volume_size`, `encrypted`, `iops` | `map(string)` | `{}` | no |
| ebs\_root\_volume\_size | The disk size | `number` | `32` | no |
| ebs\_volume\_type | The EBS type | `string` | `"gp3"` | no |
| ec2\_k8s\_workers\_instance\_type | Instance size for the nodes | `string` | n/a | yes |
| ec2\_key\_name | The key name to associate to the new ec2 servers. Not needed if you use SSM or want no access | `string` | `""` | no |
| enable\_ssm\_access\_to\_nodes | If set to true the nodes will register to AWS SSM | `bool` | `true` | no |
| k8s\_worker\_additional\_lbs | List of additional ELBs to attach to the AG for nodes (workers) | `list(string)` | `[]` | no |
| k8s\_workers\_lb\_timeout\_seconds | lb timeout in second for the nodes | `string` | `"60"` | no |
| k8s\_workers\_num\_nodes | Number of nodes for the asg for the nodes | `string` | n/a | yes |
| market\_options | Market options for the instances | `string` | `"spot"` | no |
| nodes\_config\_bundle | n/a | `any` | n/a | yes |
| nodes\_cri\_bootstrap | n/a | `string` | n/a | yes |
| private\_subnets | n/a | `any` | n/a | yes |
| sns\_topic\_notifications | The SNS topic to notify when the system autoscale. If empty no notification will be sent | `string` | `""` | no |
| userdata\_post\_install | User-data that will be applied on every node after everything else | `string` | `""` | no |
| userdata\_pre\_install | User-data that will be applied before everything else is installed | `string` | `""` | no |
| vpc\_id | The VPC id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| nodes\_sd\_id | The id of the nodes (workers) sg. Allows injection of rules aws\_security\_group\_rule |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# TODO

# TODO

- k8s-node-k8s-dev-npjcjz
- Make it single az
- Allow to install different container engines
- Possible move to use parts (template_cloudinit_config)
- check kubelet extra args if it's not deprecated
- Use random provider for better naming for some resources which name is generated by tf
- Add ability to use spot nodes
- Install the spot helper for spot nodes
- Use datasource instead of heredoc
- Change ebs partition
- Change EBS encryption
- Kill the node if the node cannot connect to the master ip
- Fix CA verification
- Change the providers to be injected instead of defining in the module
- Add tags on resources with path to the module they are defined it
- Health check on the asg is done via ELB (check for using ALB)
- Export the information needed to create a target group outside the module
- Rename all workers reference to nodes
- Fix/reduce IAM roles power
- Access logs for lbs
