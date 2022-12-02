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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCflKxoaFiBSP/Kct/HFfDRjQW9LwX4Hy6SJ+jvcIUDxjoBey5UicT7UmRcCJajknge6dEFlHLXrb2LC2yYgZlsuktdPjykVqwbbrU1K7pBImAbkTRwr6aM/sS38Tc8sNEp+G6G71TwmjN5CALL9ao7LrVpbYPXpcveFkuaO907/Cqtmpjz/VCJdyFcWp7IvS/MtjhQjNLndZJ2b8X8NeEOO6M89c7uvnU9cEMm0Tp478OpGxEVIpdTpV26gS38d1aCOLLFu5CepJVNuH1oDmYSNOtOdvAd82nPGYdYiumBVOBPh5KMwD9smTmYBVzqQqzXzhgA+UZRd7W2KnGC4D0V terraform-admin"
}


resource "aws_network_interface" "kube_instance_eni" {
  subnet_id       = data.aws_subnet.kube_subnet_id.id
  security_groups = [data.aws_security_group.kube_sg_id.id]

  
}

resource "aws_instance" "kube_dash_instance" {
  ami           = "ami-08c40ec9ead489470" # us-east-1
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
