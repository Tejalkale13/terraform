
resource "aws_cloudwatch_metric_alarm" "disk_alarms" {
  for_each = {
    for threshold in var.thresholds :
    "${var.instance_id}-${threshold}" => {
      instance_id = var.instance_id
      threshold   = threshold
    }
  }

  alarm_name          = "Disk-${each.value.instance_id}-${each.value.threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = var.platform == "linux" ? "DiskUtilization" : "LogicalDisk % Used Space"
  namespace           = var.platform == "linux" ? "System/Linux" : "System/Windows"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Disk alarm for instance ${each.value.instance_id} > ${each.value.threshold}%"
  actions_enabled     = true

  dimensions = var.platform == "linux" ? {
    InstanceId = each.value.instance_id
  } : {
    InstanceId  = each.value.instance_id
    LogicalDisk = "C:"  # Optional: you can parameterize this
  }
}
