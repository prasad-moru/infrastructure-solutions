#!/bin/bash

# PostgreSQL Installation Script for Ubuntu 24.04
set -e

# Variables
PG_VERSION="16"
VAULT_DB_NAME="vault_db"
VAULT_DB_USER="vault_user"
VAULT_DB_PASSWORD=$(openssl rand -hex 16)  # Generate random password

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

# Save credentials to file
echo "VAULT_DB_NAME=$VAULT_DB_NAME" | sudo tee /etc/vault.d/db_credentials
echo "VAULT_DB_USER=$VAULT_DB_USER" | sudo tee -a /etc/vault.d/db_credentials
echo "VAULT_DB_PASSWORD=$VAULT_DB_PASSWORD" | sudo tee -a /etc/vault.d/db_credentials
sudo chmod 600 /etc/vault.d/db_credentials

echo "PostgreSQL installed and configured successfully!"
echo "Database credentials saved to /etc/vault.d/db_credentials"