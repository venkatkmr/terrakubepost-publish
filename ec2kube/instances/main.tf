terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "kubernetes-s3-bucket-tf"
    key    = "instances-tf.state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


data "aws_subnet" "kube_subnet_id" {
  
  filter {
    name   = "tag:Name"
    values = ["kube_subnet"]
  }

#   most_recent = true
}

data "aws_security_group" "kube_sg_id" {
  
  filter {
    name   = "tag:Name"
    values = ["kube_sg"]
  }

#   most_recent = true
}

resource "aws_key_pair" "kube_cp_key" {
  key_name   = "etkube-cp-instance-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmqmcI/O/8cdbFeDM82t9RaCu2SP/fdZa9REpVL/4WoGtycbnzoX7yrSBkZ916Yyq1ShGKwh7xv+It/T52NH6LZEndiVIm/VW5HhIqA/pPLiuye6KFQd43Z58diBEM7pGQbTbdt2zCr85ZHc8RATDbcBImbPSGw92emNvw3I741ybGGiqgiqM4nIvI2Ylpcae148kXrSFJdIqr6i6d3sRKLfXqds5ROhE4D3ocLs4N/SpxSoN2KpiYAq0njiRJ+e7bpy3x4dUQdE4GDkROkQDoMPskS/LRVKiUDybpOrCbJ3+hNEmv5niR9JbrZvrua+IjUzgVFRzJ1ghzvq1SUr8l root@ip-172-31-89-46.ec2.internal"
}


resource "aws_network_interface" "kube_instance_eni" {
  subnet_id       = data.aws_subnet.kube_subnet_id.id
  security_groups = [data.aws_security_group.kube_sg_id.id]

  
}

resource "aws_instance" "kube_dash_instance" {
  ami           = "ami-0e472ba40eb589f49" # us-east-1
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = resource.aws_network_interface.kube_instance_eni.id
    device_index         = 0
  }
  availability_zone = "us-east-1a"
  key_name = resource.aws_key_pair.kube_cp_key.key_name

  tags= {
    Name = "KubeCtrlPlane"
  }

}
