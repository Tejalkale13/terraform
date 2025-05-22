locals {
  disk_threshold_matrix = flatten([
    for disk in var.disks : [
      for threshold in var.thresholds : {
        key        = "${var.instance_id}-${replace(disk, "/", "_")}-${threshold}"
        instance_id = var.instance_id
        disk        = disk
        threshold   = threshold
      }
    ]
  ])
}

  resource "aws_cloudwatch_metric_alarm" "ebs_disk_alarms" {
  for_each = {
    for item in local.disk_threshold_matrix :
    item.key => item
  }

  alarm_name          = "EBS-Disk-${each.value.instance_id}-${replace(each.value.disk, "/", "_")}-${each.value.threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarm for disk ${each.value.disk} on instance ${each.value.instance_id} > ${each.value.threshold}%"
  actions_enabled     = true

  dimensions = var.platform == "linux" ? {
    InstanceId = each.value.instance_id
    //path       = each.value.disk
    //fstype     = "ext4"  # change as needed
  } : {
    InstanceId   = each.value.instance_id
    LogicalDisk  = each.value.disk
  }
}