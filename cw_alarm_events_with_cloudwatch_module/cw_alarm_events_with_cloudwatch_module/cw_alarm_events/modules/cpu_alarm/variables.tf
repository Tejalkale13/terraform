variable "instance_id" {
  type = string
}
variable "instance_name" {
  type = string
}
variable "thresholds" {
  type = list(number)
}
variable "iam_role_name" {
  type = string
}

