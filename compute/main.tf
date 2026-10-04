locals {
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  dashboard_subnet   = data.terraform_remote_state.networking.outputs.dashboard_subnet_id
  counting_subnet    = data.terraform_remote_state.networking.outputs.counting_subnet_id
}

##########################################################
# dashboard security group
##########################################################

resource "aws_security_group" "dashboard_sg" {
  name   = "${var.prefix}-dashboard-security-group"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9009
    to_port     = 9009
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-dashboard-security-group"
  }
}

##########################################################
# counting security group
##########################################################

resource "aws_security_group" "counting_sg" {
  name   = "${var.prefix}-counting-security-group"
  vpc_id = local.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.dashboard_sg.id]
  }

  ingress {
    from_port       = 9009
    to_port         = 9009
    protocol        = "tcp"
    security_groups = [aws_security_group.dashboard_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-counting-security-group"
  }
}

##########################################################
# ssh key pair
##########################################################

resource "tls_private_key" "counting_dashboard_key" {
  algorithm = "ED25519"
}

locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

resource "aws_key_pair" "counting_dashboard_keypair" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.counting_dashboard_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.counting_dashboard_key.private_key_openssh
  filename        = local.private_key_filename
  file_permission = "0400"
}

##########################################################
# counting instance (private subnet)
##########################################################

resource "aws_instance" "counting_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.counting_dashboard_keypair.key_name
  associate_public_ip_address = false
  subnet_id                   = local.counting_subnet
  vpc_security_group_ids      = [aws_security_group.counting_sg.id]

  tags = {
    Name       = "${var.prefix}-counting-instance"
    Department = var.department
  }
}

##########################################################
# dashboard instance (public subnet)
##########################################################

resource "aws_instance" "dashboard_instance" {
  depends_on             = [aws_instance.counting_instance]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.counting_dashboard_keypair.key_name
  subnet_id              = local.dashboard_subnet
  vpc_security_group_ids = [aws_security_group.dashboard_sg.id]

  tags = {
    Name       = "${var.prefix}-dashboard-instance"
    Department = var.department
  }
}

##########################################################
# elastic ip for dashboard instance
##########################################################

resource "aws_eip" "counting_dashboard" {
  instance = aws_instance.dashboard_instance.id
  domain   = "vpc"
}

resource "aws_eip_association" "counting_dashboard" {
  instance_id   = aws_instance.dashboard_instance.id
  allocation_id = aws_eip.counting_dashboard.id
}
