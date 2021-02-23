resource "random_string" "seed" {
  length  = 6
  lower   = true
  upper   = false
  number  = true
  special = false
}

data "template_cloudinit_config" "controller_bootstrap" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "boostrap.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap_node_k8s_controllers.rendered
  }

}

resource "aws_launch_template" "controller" {
  name                                 = "kubernetes-node-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}"
  instance_initiated_shutdown_behavior = "terminate"
  image_id                             = var.ami_id != "" ? var.ami_id : data.aws_ami.ami_dynamic.id
  instance_type                        = var.ec2_k8s_controllers_instance_type
  vpc_security_group_ids               = [aws_security_group.k8s_controllers_node_sg.id]
  user_data                            = data.template_cloudinit_config.controller_bootstrap.rendered
  key_name                             = var.enable_ssm_access_to_nodes ? null : var.ec2_key_name
  tags                                 = local.tags_as_map

  dynamic "block_device_mappings" {
    for_each = [var.block_device_mappings]

    content {
      device_name = "/dev/sda1" # root

      ebs {
        delete_on_termination = lookup(block_device_mappings.value, "delete_on_termination", true) # cattle not pets
        volume_type           = lookup(block_device_mappings.value, "volume_type", var.ebs_volume_type)
        volume_size           = lookup(block_device_mappings.value, "volume_size", var.ebs_root_volume_size)
        encrypted             = lookup(block_device_mappings.value, "encrypted", true)
        iops                  = lookup(block_device_mappings.value, "iops", null)
      }
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.k8s_instance_profile.id
  }

  //  instance_market_options {
  //    market_type = var.market_options
  //    spot_options {
  //      spot_instance_type = "one-time" # Auto Scaling only supports the 'one-time' Spot instance type with no duration.
  //    }
  //  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags_as_map
  }
}


resource "aws_autoscaling_group" "k8s_controllers_ag" {
  max_size         = var.k8s_controllers_num_nodes
  min_size         = var.k8s_controllers_num_nodes
  desired_capacity = var.k8s_controllers_num_nodes
  //  launch_configuration      = aws_launch_configuration.k8s_controllers_launch_configuration.id
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = false
  metrics_granularity       = "1Minute"
  wait_for_capacity_timeout = "10m"
  vpc_zone_identifier       = aws_subnet.k8s_private.*.id

  launch_template {
    id      = aws_launch_template.controller.id
    version = "$Latest"
  }

  load_balancers = [
    aws_elb.k8s_controllers_internal_elb.name,
  ]

  termination_policies = [
    "OldestInstance",
  ]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = local.tags_for_asg
    content {
      key                 = tag.value["key"]
      value               = tag.value["value"]
      propagate_at_launch = tag.value["propagate_at_launch"]
    }
  }
}
