resource "aws_iam_role" "cw_ssm_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.cw_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.cw_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_instance_profile" "cw_ssm_instance_profile" {
  name = "${var.role_name}_instance_profile"
  role = aws_iam_role.cw_ssm_role.name
}

resource "aws_iam_instance_profile_attachment" "attach_profile" {
  instance_id = var.instance_id
  iam_instance_profile = aws_iam_instance_profile.cw_ssm_instance_profile.name
}
