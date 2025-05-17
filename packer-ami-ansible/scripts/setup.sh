#!/bin/bash
set -e

echo "Updating apt cache..."
sudo apt update -y

echo "Installing software-properties-common..."
sudo apt install -y software-properties-common

echo "Adding Ansible PPA..."
sudo add-apt-repository --yes --update ppa:ansible/ansible

echo "Installing Ansible..."
sudo apt install -y ansible

echo "Ansible installed successfully!"
