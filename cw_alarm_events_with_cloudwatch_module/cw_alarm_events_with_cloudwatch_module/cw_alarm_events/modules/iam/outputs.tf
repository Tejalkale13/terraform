output "role_name" {
  value = aws_iam_role.cw_ssm_role.name
}


output "instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.profile.name
}
