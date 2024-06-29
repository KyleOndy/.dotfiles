data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "reverse_proxy" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano" # the smallest ec2 instnace
  key_name      = module.key.name
  subnet_id     = module.dynamic_subnets.public_subnet_ids[0]
  vpc_security_group_ids = [
    aws_security_group.allow_all_egress.id,
    aws_security_group.allow_all_ingress.id,
    aws_security_group.allow_ssh.id,
  ]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "apps reverse proxy"
    Description = "app.ondy.org reverse proxy"
  }
}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

locals {
  my_ip = chomp(data.http.icanhazip.body)
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound connections"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }
}

resource "aws_security_group" "allow_all_egress" {
  name        = "allow_all_egress"
  description = "Allow all outgoing conncetions"
  vpc_id      = module.vpc.vpc_id

  egress {
    description      = "allow all egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# todo: roll my own VPC module
module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.2.0"

  ipv4_primary_cidr_block          = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = false
}

# todo: roll my own subnet module
module "dynamic_subnets" {
  source              = "cloudposse/dynamic-subnets/aws"
  version             = "2.4.2"
  nat_gateway_enabled = false
  availability_zones  = [data.aws_availability_zones.available.names[0]]
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.vpc.igw_id
  ipv4_cidr_block     = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {
  state = "available"
}

output "ec2_dns" {
  value = aws_instance.this.public_dns
}

output "keypair" {
  value = module.key.name
}
