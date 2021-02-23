resource "aws_autoscaling_notification" "elasticsearch_autoscaling_notification" {
  count     = var.sns_topic_notifications == "" ? 0 : 1
  topic_arn = var.sns_topic_notifications

  group_names = [
    aws_autoscaling_group.k8s_controllers_ag.name,
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
}
