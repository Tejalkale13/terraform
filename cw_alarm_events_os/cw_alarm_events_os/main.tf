terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.3"
}

provider "aws" {
  region = var.aws_region
}

# Fetch all instances with Environment=production
data "aws_instances" "selected" {
  instance_state_names = ["running", "stopped"]
  /*filter {
    name   = "tag:Environment"
    values = ["Production"]
  }*/

}

# Fetch detailed info per instance
data "aws_instance" "selected" {
  for_each    = toset(data.aws_instances.selected.ids)
  instance_id = each.value
}

# Build map: instance name -> instance ID
/*locals {
  instance_map = {
    for id, inst in data.aws_instance.selected :
    inst.tags["Name"] => id
    if contains(keys(inst.tags), "Name")
  }
}*/
locals {
  instance_map = {
    for id, inst in data.aws_instance.selected :
    (
      contains(keys(inst.tags), "Name") && inst.tags["Name"] != "" ?
      inst.tags["Name"] : id
    ) => id
  }
}


output "instance_tags" {
  value = {
    for id, inst in data.aws_instance.selected :
    id => inst.tags
  }
}

module "cpu_alarm" {
  source         = "./modules/cpu_alarm"
  for_each       = local.instance_map
  instance_id    = each.value
  instance_name  = each.key
  thresholds     = var.thresholds
}

module "memory_alarms" {
  source        = "./modules/memory_alarm"
  for_each      = local.instance_map
  instance_id   = each.value              # ✅ no `.id` needed
  instance_name = each.key
  thresholds    = var.thresholds
}



module "disk_alarms" {
  source        = "./modules/disk_alarms"
  for_each      = local.instance_map
  instance_id   = each.value
  instance_name = each.key
  thresholds    = var.thresholds
  platform      = var.platform
  disks         = var.disks 
 
}



module "eventbridge_rules" {
  source         = "./modules/eventbridge_rule"
  for_each       = local.instance_map

  instance_id    = each.value
  instance_name  = each.key
  events         = var.events
  aws_region     = var.aws_region
  alert_email    = var.alert_email
}

