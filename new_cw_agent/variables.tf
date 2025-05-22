variable "region" {
  default = "us-east-1"
}

variable "iam_role_name" {
  default = "cw_ssm_role1"
}



variable "cw_config_param" {
  description = "Name of the SSM parameter for CloudWatch config"
  default     = "CWAgentConfig"
}



variable "role_name" {
  description = "IAM role name"
  default     = "cw_ssm_role1"
}
