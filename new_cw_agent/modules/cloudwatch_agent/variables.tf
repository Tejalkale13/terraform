variable "instance_id" {
  description = "The EC2 instance ID"
  type        = string
}

variable "cw_config_param" {
  description = "SSM parameter name for CloudWatch Agent config"
  type        = string
}

variable "iam_role_name" {
  description = "IAM Role name to attach"
  type        = string
}
