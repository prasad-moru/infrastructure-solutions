#!/bin/bash

# PostgreSQL Installation Script for Ubuntu 24.04
set -e

# Variables
PG_VERSION="16"
VAULT_DB_NAME="vault_db"
VAULT_DB_USER="vault_user"
VAULT_DB_PASSWORD=$(openssl rand -hex 16)  # Generate random password
VAULT_CONFIG_DIR="/etc/vault.d"

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt update
sudo apt install -y wget ca-certificates gnupg

# Add PostgreSQL repository
sudo mkdir -p /usr/share/keyrings
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/postgresql.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | \
  sudo tee /etc/apt/sources.list.d/postgresql.list

# Install PostgreSQL
sudo apt update
sudo apt install -y postgresql-$PG_VERSION postgresql-client-$PG_VERSION postgresql-contrib-$PG_VERSION

# Configure PostgreSQL
echo "Configuring PostgreSQL for Vault..."

# Create vault user and database
sudo -u postgres psql <<EOF
CREATE USER $VAULT_DB_USER WITH PASSWORD '$VAULT_DB_PASSWORD';
CREATE DATABASE $VAULT_DB_NAME OWNER $VAULT_DB_USER;
ALTER USER $VAULT_DB_USER WITH CREATEDB CREATEROLE;
EOF

# Configure pg_hba.conf
echo "host    $VAULT_DB_NAME    $VAULT_DB_USER    127.0.0.1/32    scram-sha-256" | \
  sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf

# Update postgresql.conf to listen on localhost
sudo sed -i "s/^#listen_addresses =.*/listen_addresses = 'localhost'/g" /etc/postgresql/$PG_VERSION/main/postgresql.conf

# Restart PostgreSQL
sudo systemctl restart postgresql

# Create Vault config directory and save credentials
echo "Creating Vault configuration directory..."
sudo mkdir -p $VAULT_CONFIG_DIR
echo "VAULT_DB_NAME=$VAULT_DB_NAME" | sudo tee $VAULT_CONFIG_DIR/db_credentials
echo "VAULT_DB_USER=$VAULT_DB_USER" | sudo tee -a $VAULT_CONFIG_DIR/db_credentials
echo "VAULT_DB_PASSWORD=$VAULT_DB_PASSWORD" | sudo tee -a $VAULT_CONFIG_DIR/db_credentials
sudo chmod 600 $VAULT_CONFIG_DIR/db_credentials

echo ""
echo "PostgreSQL installed and configured successfully!"
echo "Database credentials saved to $VAULT_CONFIG_DIR/db_credentials"
echo ""
echo "You can now proceed with Vault installation using Ansible."