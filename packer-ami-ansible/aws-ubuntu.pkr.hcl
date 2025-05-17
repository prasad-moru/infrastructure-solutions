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
  instance_type = "t2.medium"
  region        = "us-west-2"
  source_ami    = "ami-0d1c82c20e5133e0e"
  ssh_keypair_name = "newkey"
  ssh_private_key_file = "/home/prasadmoru/.ssh/newkey.pem"
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Installing Redis",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y redis-server",
      "sudo apt-get install -y nginx",
      "echo \"FOO is $FOO\" > example.txt",
    ]
  }
}
