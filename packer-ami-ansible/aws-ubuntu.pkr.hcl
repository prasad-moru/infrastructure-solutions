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

  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      # Added your requested commands
      "cd /home/ubuntu/infrastucture-solutions || mkdir -p /home/ubuntu/infrastucture-solutions",
      "git pull || echo 'Git pull failed - may need to clone repository first'",
      "cat /home/ubuntu/infrastucture-solutions/testing.txt || echo 'File not found'",
      "cd /home/ubuntu/infrastucture-solutions/sonarqube/ || echo 'Sonarqube directory not found'",
      "ansible-playbook -i inventory.ini site.yml || echo 'Ansible playbook execution failed'"
    ]
  }
}