variable "instance_id" {
  type = string
}
variable "instance_name" {
  type = string
}
variable "thresholds" {
  type = list(number)
}
/*variable "platform" {
  description = "The platform of the instance (linux or windows)"
  type        = string
  validation {
    condition     = contains(["linux", "windows"], lower(var.platform))
    error_message = "Platform must be either 'linux' or 'windows'."
  }
}*/
variable "platform" {
  type = string
  description = "Either 'linux' or 'windows'"
}



