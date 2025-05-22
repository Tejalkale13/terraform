resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  for_each = {
    for threshold in var.thresholds :
    "${var.instance_id}-${threshold}" => {
      instance_id = var.instance_id
      threshold   = threshold
    }
  }

  alarm_name          = "CPU-${each.value.instance_id}-${each.value.threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "CPU alarm for instance ${each.value.instance_id} > ${each.value.threshold}%"
  dimensions = {
    InstanceId = each.value.instance_id
  }
  actions_enabled = true
}
