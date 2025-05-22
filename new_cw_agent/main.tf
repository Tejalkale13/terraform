provider "aws" {
  region = var.region
}

data "aws_instances" "selected" {
  instance_state_names = ["running", "stopped"]
}

data "aws_instance" "selected" {
  for_each    = toset(data.aws_instances.selected.ids)
  instance_id = each.value
}

locals {
  instance_map = {
    for id, inst in data.aws_instance.selected :
    (contains(keys(inst.tags), "Name") && inst.tags["Name"] != "" ? inst.tags["Name"] : id) => id
  }
}

module "iam_role" {
  source       = "./modules/iam_role"
  role_name    = var.iam_role_name
  instance_id     = each.value      
}

module "cloudwatch_agent" {
  source          = "./modules/cloudwatch_agent"
  for_each        = local.instance_map
  instance_id     = each.value                       # ✅ Correct
  cw_config_param = var.cw_config_param
  iam_role_name   = module.iam_role.role_name
}



resource "aws_iam_instance_profile_attachment" "attach_profile" {
  for_each              = local.instance_map
  instance_id           = each.value
  iam_instance_profile  = module.iam_role.instance_profile_name
}
