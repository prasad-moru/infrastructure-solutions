packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "myubunt_image-{{timestamp}}"
  instance_type = "t2.xlarge"
  region        = "us-east-1"
  source_ami    = "ami-0dd3fa5cfb0989d2d"
  ssh_keypair_name = "github_actions"
  ssh_private_key_file = "/home/prasadmoru/.ssh/github_actions.pem"
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
  source      = "deploy.sh"
  destination = "/tmp/deploy.sh"
  }
  provisioner "shell" {
  inline = [
    "chmod +x /tmp/deploy.sh",
    "/tmp/deploy.sh"
   ]
  }

}