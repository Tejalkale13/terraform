variable "thresholds" {
  type = list(number)
}

variable "events" {
  description = "List of EC2 states to monitor"
  type        = list(string)
  default     = ["terminated", "stopped", "rebooted"]
}

variable "alert_email" {
  description = "Email address to receive EC2 state change notifications"
  type        = string
}

variable "platform" {
  description = "Platform type: linux or windows"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "config_template_path" {
  description = "Path to the CloudWatch agent configuration template"
  type        = string
  default     = "./cloudwatch_agent_config.json.tpl"
}

variable "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  type        = string
  default     = "/aws/cloudwatch/agent/logs"
}

variable "iam_role_name" {
  description = "Name of the IAM Role"
  type        = string
  default     = "cw-ssm-role-new"
}


variable "retention_days" {
  description = "Retention in days for the log group"
  type        = number
}


