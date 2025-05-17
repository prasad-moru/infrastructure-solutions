curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update && sudo apt-get install packer

packer --version 

Packer v1.12.0


cd /home/ubuntu/infrastucture-solutions
git pull
cat /home/ubuntu/infrastucture-solutions/testing.txt
cd /home/ubuntu/infrastucture-solutions/sonarqube/
ansible-playbook -i inventory.ini site.yml