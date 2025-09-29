#!/bin/bash

#############################################
# Docker, Docker Compose & Minikube Setup
# For Ubuntu Server
# Author: DevOps Engineer
#############################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="devops_setup_$(date +%Y%m%d_%H%M%S).log"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then 
        print_error "Please do not run this script as root or with sudo"
        print_info "The script will prompt for sudo when needed"
        exit 1
    fi
}

# Function to check system resources
check_resources() {
    print_info "Checking system resources..."
    
    TOTAL_CPU=$(nproc)
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM / 1024))
    
    print_info "Total CPU cores: $TOTAL_CPU"
    print_info "Total Memory: ${TOTAL_MEM_GB}GB"
    
    if [ "$TOTAL_CPU" -lt 4 ]; then
        print_warning "Less than 4 CPU cores detected. Minikube may run slowly."
    fi
    
    if [ "$TOTAL_MEM_GB" -lt 8 ]; then
        print_warning "Less than 8GB RAM detected. You may need to reduce service memory limits."
    fi
}

# Function to remove old Docker installations
remove_old_docker() {
    print_info "Removing old Docker installations..."
    
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        if dpkg -l | grep -q "^ii.*$pkg"; then
            print_info "Removing $pkg..."
            sudo apt-get remove -y $pkg 2>&1 | tee -a "$LOG_FILE"
        fi
    done
    
    print_success "Old Docker packages removed"
}

# Function to install Docker
install_docker() {
    print_info "Installing Docker..."
    
    # Add Docker's official GPG key
    sudo apt-get update 2>&1 | tee -a "$LOG_FILE"
    sudo apt-get install -y ca-certificates curl 2>&1 | tee -a "$LOG_FILE"
    sudo install -m 0755 -d /etc/apt/keyrings
    
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 2>&1 | tee -a "$LOG_FILE"
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add the repository to Apt sources
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker packages
    sudo apt-get update 2>&1 | tee -a "$LOG_FILE"
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>&1 | tee -a "$LOG_FILE"
    
    # Start and enable Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    print_success "Docker installed successfully"
}

# Function to configure Docker for current user
configure_docker_user() {
    print_info "Configuring Docker for user: $USER"
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    print_success "User added to docker group"
    print_warning "You need to log out and log back in for group changes to take effect"
    print_info "Or run: newgrp docker"
}

# Function to install Docker Compose (standalone)
install_docker_compose() {
    print_info "Installing Docker Compose (standalone)..."
    
    sudo apt-get install -y docker-compose 2>&1 | tee -a "$LOG_FILE"
    
    print_success "Docker Compose installed successfully"
}

# Function to install kubectl
install_kubectl() {
    print_info "Installing kubectl..."
    
    # Download the latest kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 2>&1 | tee -a "$LOG_FILE"
    
    # Validate the binary
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" 2>&1 | tee -a "$LOG_FILE"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check 2>&1 | tee -a "$LOG_FILE"
    
    # Install kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl kubectl.sha256
    
    print_success "kubectl installed successfully"
}

# Function to install Minikube
install_minikube() {
    print_info "Installing Minikube..."
    
    # Download Minikube
    curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64 2>&1 | tee -a "$LOG_FILE"
    
    # Install Minikube
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    
    print_success "Minikube installed successfully"
}

# Function to verify installations
verify_installations() {
    print_info "Verifying installations..."
    
    echo ""
    print_info "Docker version:"
    docker --version 2>&1 | tee -a "$LOG_FILE" || print_warning "Docker not accessible (may need to re-login)"
    
    echo ""
    print_info "Docker Compose version:"
    docker compose version 2>&1 | tee -a "$LOG_FILE" || print_warning "Docker Compose plugin not accessible"
    docker-compose --version 2>&1 | tee -a "$LOG_FILE" || print_warning "Docker Compose standalone not accessible"
    
    echo ""
    print_info "kubectl version:"
    kubectl version --client 2>&1 | tee -a "$LOG_FILE"
    
    echo ""
    print_info "Minikube version:"
    minikube version 2>&1 | tee -a "$LOG_FILE"
}

# Function to show Minikube start command recommendations
show_minikube_recommendations() {
    echo ""
    print_info "=========================================="
    print_info "Minikube Setup Recommendations"
    print_info "=========================================="
    
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM / 1024))
    TOTAL_CPU=$(nproc)
    
    if [ "$TOTAL_MEM_GB" -ge 16 ]; then
        print_info "For your Spring Petclinic microservices (recommended):"
        echo -e "  ${GREEN}minikube start --cpus=6 --memory=12288 --driver=docker${NC}"
    elif [ "$TOTAL_MEM_GB" -ge 4 ]; then
        print_info "For your Spring Petclinic microservices (comfortable):"
        echo -e "  ${GREEN}minikube start --cpus=4 --memory=10240 --driver=docker${NC}"
   # elif [ "$TOTAL_MEM_GB" -ge 4 ]; then
   #     print_info "For your Spring Petclinic microservices (minimum):"
   #     echo -e "  ${GREEN}minikube start --cpus=4 --memory=8192 --driver=docker${NC}"
   #     print_warning "You may need to reduce some service memory limits"
    else
        print_warning "Limited resources detected. Try:"
        echo -e "  ${YELLOW}minikube start --cpus=2 --memory=6144 --driver=docker${NC}"
        print_warning "You will likely need to reduce service memory limits and run fewer services"
    fi
    
    echo ""
    print_info "Useful Minikube commands:"
    echo "  minikube status          - Check Minikube status"
    echo "  minikube stop            - Stop Minikube"
    echo "  minikube delete          - Delete Minikube cluster"
    echo "  minikube dashboard       - Open Kubernetes dashboard"
    echo "  minikube addons list     - List available addons"
    echo "  kubectl get nodes        - Verify Kubernetes node"
    print_info "=========================================="
}


# Main installation flow
main() {
    clear
    echo "=========================================="
    echo "Docker, Docker Compose & Minikube Setup"
    echo "=========================================="
    echo ""
    
    check_root
    check_resources
    
    echo ""
    read -p "Do you want to proceed with the installation? (y/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    remove_old_docker
    install_docker
    configure_docker_user
    install_docker_compose
    install_kubectl
    install_minikube
    verify_installations
    show_minikube_recommendations
    
    echo ""
    print_success "=========================================="
    print_success "Installation completed successfully!"
    print_success "=========================================="
    print_warning "IMPORTANT: Please log out and log back in for Docker group changes to take effect"
    print_info "Or run: newgrp docker"
    print_info "Log file saved to: $LOG_FILE"
}

# Run main function
main
