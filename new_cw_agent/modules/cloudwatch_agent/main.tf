resource "aws_ssm_document" "cw_install_script" {
  name          = "InstallCloudWatchAgent"
  document_type = "Command"
  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Install and configure CloudWatch Agent",
    mainSteps = [{
      action = "aws:runShellScript",
      name   = "installCWAgent",
      inputs = {
        runCommand = [
          "sudo yum install -y amazon-cloudwatch-agent",
          "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:${var.cw_config_param} -s"
        ]
      }
    }]
  })
}



resource "aws_ssm_association" "cw_agent_association" {
  name = aws_ssm_document.cw_install_script.name

  targets {
    key    = "InstanceIds"
    values = [var.instance_id]   # ✅ make it a list
  }
}

resource "aws_instance" "attach_role" {
  for_each = local.instance_map

  instance_id               = each.value
  iam_instance_profile      = module.iam_role.instance_profile_name

  lifecycle {
    ignore_changes = [ami, user_data, instance_type, tags]
  }
}

