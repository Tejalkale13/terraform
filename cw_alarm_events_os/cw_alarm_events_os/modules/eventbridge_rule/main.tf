locals {
  emergency_events = toset(["start", "stop"])

  priority_map = {
    "start"      = "emergency"
    "stop"       = "emergency"
    "terminated" = "critical"
    "reboot"     = "warning"
  }
}


# Create rules for all events
resource "aws_cloudwatch_event_rule" "ec2_events" {
  for_each = toset(var.events)

  name        = "${var.instance_name}-${replace(each.value, " ", "-")}-rule"
  description = "Event rule for ${each.value} (priority: ${lookup(local.priority_map, each.value, "normal")}) on instance ${var.instance_id}"

  event_pattern = jsonencode({
    source        = ["aws.ec2"],
    "detail-type" = ["EC2 Instance State-change Notification"],
    detail = {
      "state"        = [each.value],
      "instance-id"  = [var.instance_id]
    }
  })
}


# Target using dynamic block to conditionally include input_transformer
resource "aws_cloudwatch_event_target" "ec2_target" {
  for_each = toset(var.events)

  rule      = aws_cloudwatch_event_rule.ec2_events[each.value].name
  target_id = "${var.instance_name}-${replace(each.value, " ", "-")}-target"
  arn       = aws_sns_topic.ec2_state_change.arn

  dynamic "input_transformer" {
    for_each = contains(local.emergency_events, each.value) ? [1] : []
    content {
      input_paths = {
        instanceId = "$.detail.instance-id"
        state      = "$.detail.state"
      }

      input_template = <<TEMPLATE
{
  "instance_id": "<instanceId>",
  "state": "<state>",
  "priority": "${lookup(local.priority_map, each.value, "emergency")}"
}
TEMPLATE

    }
  }
}


resource "aws_sns_topic" "ec2_state_change" {
  name = "ec2-state-change-topic"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowEventBridgeToPublish",
        Effect    = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action    = "SNS:Publish",
        Resource  = "*"
      }
    ]
  })
}
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.ec2_state_change.arn
  protocol  = "email"
  endpoint  = var.alert_email # e.g., "you@example.com"
} 