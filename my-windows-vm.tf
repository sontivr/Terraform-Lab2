// https://www.terraform.io/docs/providers/aws/index.html
provider "aws" {
    // We assume you've already run an aws configure
    region = "us-west-2"
}

// https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "windows-server-rdp" {
    description = "Allow RDP connections to windows server."

    ingress {
      from_port   = "3389"
      to_port     = "3389"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

// https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "windows-server-2019" {
    ami                         = "ami-0bff712af642c77c9"
    instance_type               = "t2.micro"
    associate_public_ip_address = true

    // Here is the first reference to another resource attribute
    vpc_security_group_ids      = ["${aws_security_group.windows-server-rdp.id}"]
    // This also references a resource that we will create in the next section
    key_name                    = "${aws_key_pair.aws_provisioning_pair.key_name}"
    get_password_data           = true

    // Tag the instance with some metadata
    tags = {
      Name = "Terraform Module 1 Lab 2"
      User = "lab-user-sontivr"
    }
}

// This creates a TLS key on the fly that will be used to decrypt and encrypt the Administrator credentials for the server.
resource "tls_private_key" "provisioning_key" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

// This block uploads the public key to AWS
resource "aws_key_pair" "aws_provisioning_pair" {
  public_key = "${tls_private_key.provisioning_key.public_key_openssh}"
}



