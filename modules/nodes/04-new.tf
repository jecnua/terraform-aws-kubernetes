resource "aws_launch_template" "k8s_node" {
  count                                = signum(var.k8s_workers_num_nodes)
  name                                 = "kubernetes-node-${local.environment}-${local.kubernetes_cluster}-${random_string.seed.result}"
  instance_initiated_shutdown_behavior = "terminate"
  image_id                             = var.ami_id_worker != "" ? var.ami_id_worker : data.aws_ami.ami_dynamic.id
  instance_type                        = var.ec2_k8s_workers_instance_type
  vpc_security_group_ids               = [aws_security_group.k8s_workers_node_sg.id]
  user_data                            = base64encode(data.template_file.bootstrap_node_k8s_workers.rendered)
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

  instance_market_options {
    market_type = var.market_options
    spot_options {
      spot_instance_type = "one-time" # Auto Scaling only supports the 'one-time' Spot instance type with no duration.
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags_as_map
  }
}

resource "aws_autoscaling_group" "k8s_workers_ag" {
  count                     = signum(var.k8s_workers_num_nodes)
  name                      = "kubernetes-node-${local.environment}-${local.kubernetes_cluster}-${random_string.seed.result}"
  max_size                  = var.k8s_workers_num_nodes
  min_size                  = var.k8s_workers_num_nodes
  desired_capacity          = var.k8s_workers_num_nodes
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = var.private_subnets
  metrics_granularity       = "1Minute"
  //  wait_for_capacity_timeout = "10m"
  load_balancers = compact(
    concat(
      [aws_elb.k8s_workers_internal_elb[0].name],
      var.k8s_worker_additional_lbs,
    ),
  )

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

  launch_template {
    id      = aws_launch_template.k8s_node.0.id
    version = "$Latest"
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
