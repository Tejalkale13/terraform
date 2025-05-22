variable "role_name" {
  type        = string
  description = "IAM role name for CloudWatch Agent and SSM"
}
variable "instance_id" {
  description = "The EC2 instance ID to attach role and install CloudWatch Agent"
  type        = string
}
