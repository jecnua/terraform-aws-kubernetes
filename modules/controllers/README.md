# Kubernetes module

![](https://img.shields.io/badge/kubernetes-v1.20.x-green.svg)
![](https://img.shields.io/badge/ubuntu-20.04-blue.svg)

This module will create a new kubernetes cluster inside your VPC.

Last tested with:

        Terraform v0.14.4
        + provider registry.terraform.io/hashicorp/aws v3.22.0
        + provider registry.terraform.io/hashicorp/http v2.0.0
        + provider registry.terraform.io/hashicorp/template v2.2.0

Support:

    k8s     1.12.x      NO
    k8s     1.13.12     YES
    k8s     1.14.x      ?
    k8s     1.15.x      YES
    k8s     1.16.x      YES
    k8s     1.17.x      YES
    k8s     1.18.8      YES
    k8s     1.19.4      YES
    k8s     1.20.1      YES

## Usage

- [Utilities](../../examples/)

Remember to [generate a kubeadm token](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/#cmd-token-generate):

    kubeadm token generate

Be careful to pass the right subnets in availability_zone!

### Choose the version

You can choose what version of k8s to install passing this variables:

    k8s_deb_package_version           = "1.19.4"
    kubeadm_install_version           = "stable-1.19"

## Debug

To get the kubelet logs:

    journalctl -u kubelet

## Connect to the cluster

You can follow the guide here:

- [Utilities](../../utilities/)

## AMI

The module accepts a parameter.
If nothing is passed, the latest ubuntu will be fetched.
Only ubuntu is supported.

## Notes

The bootstrap file will create a cluster via kubeadm.

    MASTER_IP=`aws ec2 describe-instances --filters "Name=tag:k8s.io/role/master,Values=1" "Name=tag:KubernetesCluster,Values=$CLUSTER_ID" --region='us-east-1' | grep '\"PrivateIpAddress\"' | cut -d ':' -f2 | cut -d'"' -f 2 | uniq`

I use this line to find MY master (it works also if you have multiple clusters).

    $CLUSTER_ID

Must be unique per cluster.

## Gotchas

### skip-preflight-checks

While configuring a new node, I was receiving the following error:

    [preflight] Some fatal errors occurred:
    /var/lib/kubelet is not empty

As a temporary fix I added

    --skip-preflight-checks

So now the new join call is:

    kubeadm join \
    --skip-preflight-checks \
    --token=$CONTROLLER_JOIN_TOKEN $MASTER_IP

## kube-bench

- [https://github.com/aquasecurity/kube-bench](https://github.com/aquasecurity/kube-bench)

Running the CIS benchmarks on the controllers still returns 5 FAILURES:

[FAIL] 1.1.12 Ensure that the etcd data directory ownership is set to etcd:etcd (Automated)
[FAIL] 1.1.19 Ensure that the Kubernetes PKI directory and file ownership is set to root:root (Automated)
[FAIL] 1.2.6 Ensure that the --kubelet-certificate-authority argument is set as appropriate (Automated)
[FAIL] 1.2.16 Ensure that the admission control plugin PodSecurityPolicy is set (Automated)
[FAIL] 1.3.6 Ensure that the RotateKubeletServerCertificate argument is set to true (Automated)

About the following:

- 1.1.12: kubeadm doesn't manage an ETCD user on the machine, just root. So there is nothing to change there.
- 1.1.19: The directory IS owned by root. I really don't understand why it complains.

More [here](result.txt)

# Parameters

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |

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
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) |
| [template_cloudinit_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) |
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tags\_as\_map | A map of tags and values in the same format as other resources accept. This will be converted into the non-standard format that the aws\_autoscaling\_group requires. | `map(string)` | `{}` | no |
| ami\_id | The id of the AMI to use. If empty, the latest ubuntu will be used. | `string` | `""` | no |
| ami\_name\_filter\_regex | Regex to find the ami to use | `string` | `"ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"` | no |
| ami\_name\_regex | The name regex | `string` | `"^.*"` | no |
| ami\_owner | ID of the owner of the ami (example 099720109477 for Canonical) | `string` | `"099720109477"` | no |
| availability\_zone | The availability zone to use. Be careful, r4.2xlarge are still not available in C for example | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1b",<br>  "eu-west-1c"<br>]</pre> | no |
| block\_device\_mappings | The EC2 instance block device configuration. Takes the following keys: `delete_on_termination`, `volume_type`, `volume_size`, `encrypted`, `iops` | `map(string)` | `{}` | no |
| controller\_join\_token | kubeadm control join token. This needs to be unique for each cluster | `string` | n/a | yes |
| controllers\_cri\_bootstrap | n/a | `string` | n/a | yes |
| ebs\_root\_volume\_size | The disk size | `number` | `32` | no |
| ebs\_volume\_type | The EBS type | `string` | `"gp3"` | no |
| ec2\_k8s\_controllers\_instance\_type | Instance size for the nodes | `string` | n/a | yes |
| ec2\_key\_name | The key name to associate to the new ec2 servers. Not needed if you use SSM or want no access | `string` | `""` | no |
| enable\_admission\_plugins | The comma separated list of admission plugin to enable | `string` | `"NodeRestriction"` | no |
| enable\_ssm\_access\_to\_nodes | If set to true the nodes will register to AWS SSM | `bool` | `true` | no |
| environment | The environment to use | `string` | n/a | yes |
| internal\_network\_cidr | TEMPORARY: Allow access from a certain ip range | `string` | n/a | yes |
| k8s\_controllers\_lb\_timeout\_seconds | lb timeout in seconds for the controllers | `string` | `"60"` | no |
| k8s\_controllers\_num\_nodes | Number of nodes in the asg for the controllers | `string` | n/a | yes |
| k8s\_deb\_package\_version | The version of the deb package to install in ubuntu (i.e. 1.20.2) | `string` | `"1.20.4"` | no |
| kubeadm\_install\_version | The version to install in the syntax expected by kubeadm (i.e. stable-1.20) | `string` | `"stable-1.20"` | no |
| kubernetes\_cluster | Cluster name indentifier | `string` | n/a | yes |
| sns\_topic\_notifications | The SNS topic to notify when the system autoscale. If empty no notification will be sent | `string` | `""` | no |
| subnets\_private\_cidr\_block | The CIDR to use when creating private subnets | `list(string)` | n/a | yes |
| subnets\_public\_cidr\_block | The CIDR to use when creating public subnets | `list(string)` | n/a | yes |
| unique\_identifier | A UUID to be used in resource names generation to avoid conflicts | `string` | n/a | yes |
| userdata\_cni\_install | User-data script that will be applied only in master | `string` | `"su \"$KCTL_USER\" -c \"kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml\""` | no |
| userdata\_post\_install | User-data that will be applied on every node after everything else | `string` | `""` | no |
| userdata\_pre\_install | User-data that will be applied before everything else is installed | `string` | `""` | no |
| vpc\_id | The VPC id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| controller\_elb\_internal\_dns\_name | The AWS DNS name of the controller nodes ELB |
| controller\_elb\_internal\_zone\_id | The AWS zone id for the controller nodes ELB |
| controller\_join\_token | n/a |
| k8s\_deb\_package\_version | n/a |
| k8s\_role\_id | The role the nodes use. Can be used to attach policies |
| kubernetes\_cluster | n/a |
| nodes\_config\_bundle | n/a |
| nodes\_subnets\_private\_id | The nodes subnets id |
| nodes\_subnets\_public\_id | The nodes subnets id |
| private\_route\_table\_id | The id of the PRIVATE route table |
| public\_route\_table\_id | The id of the PUBLIC route table |
| unique\_identifier | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# TODO

- Possible move to use parts (template_cloudinit_config)
- check kubelet extra args if it's not deprecated
- Use the loadbalancer to register to the masters
- Use random provider for better naming for some resources which name is generated by tf
- Use datasource instead of heredoc
- Change ebs partition
- Change EBS encryption
- Fix CA verification
- Make KCTL_USER parametric
- FIX the bash
- Change the providers to be injected instead of defining in the module
- FIX internal_network_cidr
- Add a random provider to generate something flexible to use in naming
- Add tags on resources with path to the module they are defined it
- Health check on the asg is done via ELB (check for using ALB)
- Export the information needed to create a target group outside the module
- Fix/reduce IAM roles power
- Access logs for lbs
