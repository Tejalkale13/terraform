resource "aws_cloudwatch_log_group" "cw_logs" {
  name              = "${var.log_group_name}-${var.instance_id}"
  retention_in_days = var.retention_days
}

data "template_file" "agent_config" {
  template = file("${path.module}/${var.config_template_path}")

  vars = {
    log_group_name = "${var.log_group_name}-${var.instance_id}"
    region         = var.region
    instance_id    = var.instance_id
  }
}

resource "aws_ssm_parameter" "cw_agent_config" {
  name   = "/cloudwatch-agent/config-${var.instance_id}"
  type   = "String"
  value  = data.template_file.agent_config.rendered
  overwrite = true
}

resource "aws_ssm_document" "install_cw_agent" {
  name          = "InstallCloudWatchAgent-${var.instance_id}"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Install and start CloudWatch Agent via Terraform"
    mainSteps = [
      {
        action = "aws:runShellScript",
        name   = "InstallAgent",
        inputs = {
          runCommand = [
            "sudo snap remove amazon-ssm-agent || true",
            "sudo snap install amazon-ssm-agent --classic || true",
            "sudo systemctl enable amazon-ssm-agent",
            "sudo systemctl start amazon-ssm-agent",
            "sudo yum install -y amazon-cloudwatch-agent || sudo apt-get install -y amazon-cloudwatch-agent",
            "/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:/cloudwatch-agent/config-${var.instance_id} -s"
          ]
        }
      }
    ]
  })
}

resource "aws_ssm_association" "start_agent" {
  name = aws_ssm_document.install_cw_agent.name

  targets {
    key    = "InstanceIds"
    values = [var.instance_id]
  }

  depends_on = [
    aws_ssm_parameter.cw_agent_config,
    aws_cloudwatch_log_group.cw_logs
  ]
}
