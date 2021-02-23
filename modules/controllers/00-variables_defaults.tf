variable "additional_tags_as_map" {
  description = "A map of tags and values in the same format as other resources accept. This will be converted into the non-standard format that the aws_autoscaling_group requires."
  type        = map(string)
  default     = {}
}

variable "ami_name_filter_regex" {
  type        = string
  description = "Regex to find the ami to use"
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "ami_id" {
  type        = string
  description = "The id of the AMI to use. If empty, the latest ubuntu will be used."
  default     = ""
}

variable "ami_owner" {
  type        = string
  description = "ID of the owner of the ami (example 099720109477 for Canonical)"
  default     = "099720109477"
}

variable "ami_name_regex" {
  type        = string
  description = "The name regex"
  default     = "^.*"
}

variable "availability_zone" {
  type        = list(string)
  description = "The availability zone to use. Be careful, r4.2xlarge are still not available in C for example"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "k8s_controllers_lb_timeout_seconds" {
  type        = string
  description = "lb timeout in seconds for the controllers"
  default     = "60"
}

variable "sns_topic_notifications" {
  type        = string
  description = "The SNS topic to notify when the system autoscale. If empty no notification will be sent"
  default     = ""
}

variable "k8s_deb_package_version" {
  type        = string
  description = "The version of the deb package to install in ubuntu (i.e. 1.20.2)"
  default     = "1.20.4"
}

variable "kubeadm_install_version" {
  type        = string
  description = "The version to install in the syntax expected by kubeadm (i.e. stable-1.20)"
  default     = "stable-1.20"
}

variable "userdata_pre_install" {
  description = "User-data that will be applied before everything else is installed"
  type        = string
  default     = ""
}

# By default will install calico as CNI but you can override it to use what you want
# Example of weave as alternative (remember to escape the "):
# su "$KCTL_USER" -c "kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
variable "userdata_cni_install" {
  description = "User-data script that will be applied only in master"
  type        = string
  default     = "su \"$KCTL_USER\" -c \"kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml\""
}

variable "userdata_post_install" {
  description = "User-data that will be applied on every node after everything else"
  type        = string
  default     = ""
}

variable "enable_ssm_access_to_nodes" {
  description = "If set to true the nodes will register to AWS SSM"
  type        = bool
  default     = true
}

variable "ec2_key_name" {
  type        = string
  description = "The key name to associate to the new ec2 servers. Not needed if you use SSM or want no access"
  default     = ""
}

variable "enable_admission_plugins" {
  type        = string
  description = "The comma separated list of admission plugin to enable"
  default     = "NodeRestriction" # Def for 1.19
}

variable "block_device_mappings" {
  type        = map(string)
  description = "The EC2 instance block device configuration. Takes the following keys: `delete_on_termination`, `volume_type`, `volume_size`, `encrypted`, `iops`"
  default     = {}
}

variable "ebs_root_volume_size" {
  type        = number
  description = "The disk size"
  default     = 32
}

variable "ebs_volume_type" {
  type        = string
  description = "The EBS type"
  default     = "gp3"
}

//variable "market_options" {
//  type        = string
//  description = "Market options for the instances"
//  default     = "spot"
//}
