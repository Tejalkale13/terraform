variable "instance_id" {
  description = "The ID of the EC2 instance."
  type        = string
}

variable "instance_name" {
  description = "The name of the EC2 instance."
  type        = string
}

variable "events" {
  description = "List of EC2 states to monitor"
  type        = list(string)
  default     = ["terminated", "stopped", "rebooting"]
}




variable "aws_region" {
  description = "The AWS region."
  type        = string
}
variable "alert_email" {
  description = "Email address to receive EC2 state change notifications"
  type        = string
}
