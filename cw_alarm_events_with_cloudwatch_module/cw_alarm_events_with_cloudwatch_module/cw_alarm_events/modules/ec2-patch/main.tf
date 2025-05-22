data "aws_instance" "target" {
  instance_id = data.aws_instances.filtered.ids
}

resource "aws_ec2_instance_state" "stop_instance" {
  instance_id = data.aws_instances.filtered.ids
  state       = "stopped"
}

resource "aws_ec2_instance_state" "start_instance" {
  instance_id = data.aws_instances.filtered.ids
  state       = "running"
  depends_on  = [aws_ec2_instance_state.stop_instance]
}

resource "aws_launch_template" "attach_profile" {
  name_prefix            = "patch-profile-"
  iam_instance_profile {
    name = var.iam_instance_profile
  }

  instance_type          = data.aws_instance.target.instance_type
  image_id               = data.aws_instance.target.ami
  key_name               = data.aws_instance.target.key_name
}
