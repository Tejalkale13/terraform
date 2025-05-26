resource "aws_cloudwatch_dashboard" "rds_dashboard" {
  dashboard_name = "rds-monitoring-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "title" : "RDS CPU Utilization",
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-south-1",
          "stat" : "Average",
          "period" : 300,
          "metrics" : [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "database-1"],
            ["...", "database-2"],
            ["...", "database-new"],
            ["...", "database-latest"]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "title" : "RDS Freeable Memory",
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-south-1",
          "stat" : "Average",
          "period" : 300,
          "metrics" : [
            ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "database-1"],
            ["...", "database-2"],
            ["...", "database-new"],
            ["...", "database-latest"]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 12,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "title" : "RDS Free Storage Space",
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-south-1",
          "stat" : "Average",
          "period" : 300,
          "metrics" : [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "database-1"],
            ["...", "database-2"],
            ["...", "database-new"],
            ["...", "database-latest"]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 18,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "title" : "RDS Database Connections",
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-south-1",
          "stat" : "Average",
          "period" : 300,
          "metrics" : [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "database-1"],
            ["...", "database-2"],
            ["...", "database-new"],
            ["...", "database-latest"]
          ]
        }
      }
    ]
  })
}

