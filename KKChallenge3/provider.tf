terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.15.0"
    }
  }
}

provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_requesting_account_id  = true

endpoints {
    ec2            = "http://aws:4566"
    apigateway     = "http://aws:4566"
    cloudformation = "http://aws:4566"
    cloudwatch     = "http://aws:4566"
    dynamodb       = "http://aws:4566"
    es             = "http://aws:4566"
    firehose       = "http://aws:4566"
    iam            = "http://aws:4566"
    kinesis        = "http://aws:4566"
    lambda         = "http://aws:4566"
    route53        = "http://aws:4566"
    redshift       = "http://aws:4566"
    s3             = "http://aws:4566"
    secretsmanager = "http://aws:4566"
    ses            = "http://aws:4566"
    sns            = "http://aws:4566"
    sqs            = "http://aws:4566"
    ssm            = "http://aws:4566"
    stepfunctions  = "http://aws:4566"
    sts            = "http://aws:4566"
  }
}

resource "aws_key_pair" "citadel-key" {
  key_name   = "citadel"
  public_key = file("/root/terraform-challenges/project-citadel/.ssh/ec2-connect-key.pub")
}

variable "ami" {
  description = "Amazon machine image for instance"
  default = "ami-06178cf087598769c"
}

variable "region" {
  description = "Aws region"
  default = "eu-west-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  default = "m5.large"
}

resource "aws_instance" "citadel" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.citadel-key.id
  user_data = file("/root/terraform-challenges/project-citadel/install-nginx.sh")
}

resource "aws_eip" "eip" {
  instance = aws_instance.citadel.id
  vpc = true

  provisioner "local-exec" {
    command = "echo ${aws_eip.eip.public_dns} > /root/citadel_public_dns.txt"
    interpreter = [
      "/bin/sh", "-c"
    ]
  }
  
}

