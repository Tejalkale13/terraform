variable "instance_id" {
  description = "ID of the EC2 instance"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  type        = string
}

variable "retention_days" {
  description = "Retention in days for the log group"
  type        = number
}

variable "config_template_path" {
  description = "Path to the CloudWatch agent config template"
  type        = string
}

variable "platform" {
  description = "Platform (linux/windows) of the EC2 instance"
  type        = string
}
