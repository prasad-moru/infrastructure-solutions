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


ansible --version
################################################################################################3333333333

############### shell script for ansible installation. ################################################

########################################################################################################



#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Ansible installation and setup script...${NC}"

# Step 1: Check if Ansible is installed
if command -v ansible &> /dev/null; then
    echo -e "${GREEN}Ansible is already installed.${NC}"
    ansible --version
else
    echo -e "${YELLOW}Ansible is not installed. Installing now...${NC}"
    
    # Step 2: Install Ansible
    sudo apt update -y
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to update package list. Exiting.${NC}"
        exit 1
    fi
    
    sudo apt install -y software-properties-common
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install software-properties-common. Exiting.${NC}"
        exit 1
    fi
    
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to add Ansible repository. Exiting.${NC}"
        exit 1
    fi
    
    sudo apt install -y ansible
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install Ansible. Exiting.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Ansible has been successfully installed.${NC}"
fi

# Step 3: Show Ansible version
echo -e "${YELLOW}Ansible version:${NC}"
ansible --version

# Step 4: Set up for local configuration
echo -e "${YELLOW}Setting up local configuration...${NC}"

# Generate SSH keys if they don't exist
SSH_KEY_PATH="/home/$USER/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo -e "${YELLOW}Generating SSH keys...${NC}"
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N ""
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to generate SSH keys. Exiting.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}SSH keys already exist at $SSH_KEY_PATH${NC}"
fi

# Add public key to authorized_keys
AUTH_KEYS_PATH="/home/$USER/.ssh/authorized_keys"
mkdir -p "/home/$USER/.ssh"
touch "$AUTH_KEYS_PATH"
chmod 700 "/home/$USER/.ssh"
chmod 600 "$AUTH_KEYS_PATH"

if ! grep -q "$(cat ${SSH_KEY_PATH}.pub)" "$AUTH_KEYS_PATH"; then
    echo -e "${YELLOW}Adding public key to authorized_keys...${NC}"
    cat "${SSH_KEY_PATH}.pub" >> "$AUTH_KEYS_PATH"
else
    echo -e "${GREEN}Public key is already in authorized_keys.${NC}"
fi

# Check SSH connection to localhost
echo -e "${YELLOW}Testing SSH connection to localhost...${NC}"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new localhost exit &>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}SSH connection to localhost successful.${NC}"
else
    echo -e "${RED}SSH connection to localhost failed. Please check your SSH configuration.${NC}"
    # Continue anyway, as the user might want to fix this manually
fi

# Add localhost to /etc/ansible/hosts if not already present
HOSTS_FILE="/etc/ansible/hosts"
if [ ! -f "$HOSTS_FILE" ]; then
    echo -e "${YELLOW}Creating Ansible hosts file...${NC}"
    sudo mkdir -p /etc/ansible
    echo "localhost" | sudo tee "$HOSTS_FILE" > /dev/null
else
    if ! grep -q "^localhost" "$HOSTS_FILE"; then
        echo -e "${YELLOW}Adding localhost to Ansible hosts file...${NC}"
        echo "localhost" | sudo tee -a "$HOSTS_FILE" > /dev/null
    else
        echo -e "${GREEN}localhost is already in Ansible hosts file.${NC}"
    fi
fi

# Test Ansible connection
echo -e "${YELLOW}Testing Ansible connection...${NC}"
ansible -m ping all
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Ansible is correctly configured and working.${NC}"
else
    echo -e "${RED}Ansible ping test failed. Please check your configuration.${NC}"
fi

echo -e "${GREEN}Ansible installation and setup script completed.${NC}"