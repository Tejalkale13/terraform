variable "instance_id" {
  type = string
}
variable "instance_name" {
  type = string
}
variable "thresholds" {
  type = list(number)
}

variable "platform" {
  type = string
  description = "Either 'linux' or 'windows'"
}

variable "disks" {
  type = list(string)
  description = "List of mount points (Linux) or drive letters (Windows) to monitor"
  # Example:
  # ["C:", "D:"] for Windows
  # ["/", "/mnt/data"] for Linux
}


