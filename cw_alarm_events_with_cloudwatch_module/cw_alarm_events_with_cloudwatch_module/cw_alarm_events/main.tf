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
  region = var.region
}

# Fetch EC2 instances
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

module "iam" {
  source        = "./modules/iam"
  iam_role_name = var.iam_role_name
}

module "cpu_alarm" {
  source         = "./modules/cpu_alarm"
  for_each       = local.instance_map
  instance_id    = each.value
  instance_name  = each.key
  thresholds     = var.thresholds
  iam_role_name  = var.iam_role_name
}

module "memory_alarms" {
  source        = "./modules/memory_alarm"
  for_each      = local.instance_map
  instance_id   = each.value
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
}

module "eventbridge_rules" {
  source         = "./modules/eventbridge_rule"
  for_each       = local.instance_map
  instance_id    = each.value
  instance_name  = each.key
  events         = var.events
  aws_region     = var.region
  alert_email    = var.alert_email
}

# --------------- Inline SSM Agent Install Script ---------------
resource "aws_ssm_document" "install_ssm_agent" {
  name          = "InstallSSMAgent"
  document_type = "Command"
  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Install and start the SSM Agent",
    mainSteps = [{
      action = "aws:runShellScript",
      name   = "installSSMAgent",
      inputs = {
        runCommand = [
          "#!/bin/bash",
          "if [ -f /etc/system-release ]; then",
          "  yum install -y amazon-ssm-agent",
          "  systemctl enable amazon-ssm-agent",
          "  systemctl start amazon-ssm-agent",
          "elif [ -f /etc/debian_version ]; then",
          "  snap install amazon-ssm-agent --classic",
          "  systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service",
          "  systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service",
          "fi"
        ]
      }
    }]
  })
}

resource "aws_ssm_association" "install_ssm" {
  for_each = toset(data.aws_instances.selected.ids)

  name = aws_ssm_document.install_ssm_agent.name
  targets {
    key    = "InstanceIds"
    values = [each.key]
  }
}

# --------------- CloudWatch Agent Setup ---------------
resource "aws_ssm_association" "cw_agent_configure" {
  for_each = toset(data.aws_instances.selected.ids)

  name = "AmazonCloudWatch-ManageAgent"

  targets {
    key    = "InstanceIds"
    values = [each.key]
  }

  parameters = {
    action                        = "configure"
    mode                          = "ec2"
    optionalConfigurationSource   = "ssm"
    optionalConfigurationLocation = "/cloudwatch-agent/config"
    optionalRestart               = "yes"
  }

  schedule_expression = "rate(1 day)"
  compliance_severity = "HIGH"
}

module "cloudwatch_agent" {
  source               = "./modules/cloudwatch_agent"
  for_each             = local.instance_map
  instance_id          = each.value
  region               = var.region
  log_group_name       = var.log_group_name
  config_template_path = var.config_template_path
  retention_days       = var.retention_days
  platform             = var.platform
} 
