variable "instance_id" {
  description = "EC2 Instance ID"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "os_type" {
  description = "Operating system type: linux or windows"
  type        = string
  default     = "linux"
}

variable "thresholds" {
  type = list(number)
}