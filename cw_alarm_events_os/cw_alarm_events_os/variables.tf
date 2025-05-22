variable "aws_region" {
  type    = string
  default = "us-east-1"
}

/*variable "instance_map" {
  type = map(string)
}

variable "instance_id" {
  type = string
}

variable "instance_name" {
  type = string
}*/
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


variable "disks" {
  type        = list(string)
  description = "List of mount points (Linux) or drive letters (Windows) to monitor"
}

/*variable "instance_id" {
  description = "ID of the existing EC2 instance"
  type        = string
}*/

