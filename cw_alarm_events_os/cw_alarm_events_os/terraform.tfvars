aws_region = "ap-south-1"

/*instance_map = {
  //"cloudwatch_ec2" = "i-09c9d659215c7c7f0",
  "demo" = "i-0bd2b69672b1a9c68"
}*/
thresholds = [40, 80, 90]


alert_email = "tejal13599@gmail.com"
 
disks = ["/dev/xvda"]  # for Linux