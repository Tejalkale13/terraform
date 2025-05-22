resource  "aws_cloudwatch_metric_alarm" "memory_alarms" {
  for_each = {
    for metric, threshold in var.thresholds :
    "${var.instance_id}-${metric}" => {
      metric     = metric
      threshold  = threshold
      instance_id = var.instance_id
    }
  }

  alarm_name          = "Memory-${each.value.metric}-${each.value.threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = each.value.metric
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarm for ${each.value.metric} on instance ${each.value.instance_id} > ${each.value.threshold}"
  dimensions = var.os_type == "linux" ? {
    InstanceId = each.value.instance_id,
    ImageId = "Linux" // Optional: Remove or change if not used in your CWAgent config
  } : {
    InstanceId = each.value.instance_id,
    ImageId = "Windows" // Optional
  }

  actions_enabled = true
  treat_missing_data  = "notBreaching"
  alarm_actions = ["arn:aws:sns:ap-south-1:980636705122:high-ram-cross-ac"]
  ok_actions    = ["arn:aws:sns:ap-south-1:980636705122:high-ram-cross-ac"]
}