

output "instance_profile_name" {
  value = aws_iam_instance_profile.cw_ssm_instance_profile.name
}
