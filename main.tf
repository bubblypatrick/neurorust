provider "aws" {
  region = "us-west-2" # change this if you want a different region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh.id]

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    apt-get update -y
    DEBIAN_FRONTEND=noninteractive \
      apt-get install -y openssh-server ec2-instance-connect docker.io
    systemctl restart ssh

    # run or re-run on every boot. Keeps me from having to inspect the container in AWS to make sure it's not stale, old code.
    cloud-init-per always docker-run \
      docker run -d --restart unless-stopped -p 80:3000 \
        ghcr.io/bubblypatrick/neurorust:latest
  EOF

  tags = {
    Name = "neurorust"
  }
}

### Resources allowing access to EC2 via AWS's SSH from within console

data "aws_vpc" "default" {
  default = true
}

data "aws_ec2_managed_prefix_list" "eic" {
  name = "com.amazonaws.us-west-2.ec2-instance-connect"
}

resource "aws_security_group" "ssh" {
  name   = "neurorust-ssh"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.eic.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### End AWS SSH Setup