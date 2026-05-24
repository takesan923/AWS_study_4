data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "api" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_ec2_1b.id
  iam_instance_profile   = aws_iam_instance_profile.api_ec2.name
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host    = aws_db_instance.main.address
    secret_arn = aws_secretsmanager_secret.db_pass.arn
    aws_region = var.aws_region
  }))

  tags = { Name = "api-ec2" }
}

resource "aws_lb_target_group_attachment" "api" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.api.id
  port             = 8080
}
