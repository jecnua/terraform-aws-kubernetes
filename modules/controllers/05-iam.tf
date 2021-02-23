resource "aws_iam_instance_profile" "k8s_instance_profile" {
  name_prefix = "${var.unique_identifier}-${var.environment}-"
  role        = aws_iam_role.k8s_assume_role.name
}

# For sure restrict the ZONE and VPC
resource "aws_iam_role_policy" "k8s_role" {
  name = "${var.unique_identifier}-${var.environment}-pol"
  role = aws_iam_role.k8s_assume_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {"Effect": "Allow", "Action": ["ec2:*"], "Resource": ["*"]},
    {"Effect": "Allow", "Action": ["elasticloadbalancing:*"], "Resource": ["*"]},
    {"Effect": "Allow", "Action": ["route53:*"], "Resource": ["*"]},
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role" "k8s_assume_role" {
  name_prefix = "${var.unique_identifier}-${var.environment}-"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.${data.aws_partition.current.dns_suffix}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm_policy_att" {
  count      = var.enable_ssm_access_to_nodes ? 1 : 0
  depends_on = [aws_iam_role.k8s_assume_role]
  role       = aws_iam_role.k8s_assume_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
