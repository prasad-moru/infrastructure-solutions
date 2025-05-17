#!/bin/bash
# deploy.sh - Simple deployment script

# Exit on any error
set -e

echo "Starting deployment process..."

# 1. Change to the infrastructure solutions directory
cd /home/ubuntu/infrastucture-solutions || {
  echo "ERROR: Directory /home/ubuntu/infrastucture-solutions does not exist"
  exit 1
}

# 2. Pull latest changes
echo "Pulling latest changes from git repository..."
git pull || {
  echo "ERROR: Git pull failed"
  exit 1
}

# 3. Display contents of testing.txt
echo "Contents of testing.txt:"
cat /home/ubuntu/infrastucture-solutions/testing.txt || {
  echo "WARNING: Could not display testing.txt file"
}

# 4. Change to the sonarqube directory
cd /home/ubuntu/infrastucture-solutions/sonarqube/ || {
  echo "ERROR: Sonarqube directory does not exist"
  exit 1
}

# 5. Run Ansible playbook
echo "Running Ansible playbook..."
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory.ini site.yml --ssh-common-args='-o StrictHostKeyChecking=no' || {
  echo "ERROR: Ansible playbook execution failed"
  exit 1
}

echo "Deployment completed successfully!"