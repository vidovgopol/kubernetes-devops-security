data "aws_ssm_parameter" "ubuntu_image" {
  provider = aws.mumbai
  name     = replace("/aws/service/canonical/ubuntu/server/22.04/stable/current/{{MACHINE_TYPE}}/hvm/ebs-gp2/ami-id", "{{MACHINE_TYPE}}", var.machine_type)
}

resource "random_shuffle" "subnet_for_devsecops" {
  input        = data.aws_subnets.public_subnets.ids
  result_count = 1
}
