#!/bin/bash

# This script will diagnose and fix PostgreSQL installation issues on Ubuntu 24.04 LTS

echo "==== PostgreSQL Diagnostic and Fix Script for Ubuntu 24.04 LTS ===="

# Check if PostgreSQL is installed
if dpkg -l | grep postgresql; then
  echo "✅ PostgreSQL is installed"
else
  echo "❌ PostgreSQL is not installed. Installing..."
  sudo apt update
  sudo apt install -y postgresql postgresql-contrib
fi

# Check PostgreSQL service status
if systemctl is-active postgresql; then
  echo "✅ PostgreSQL service is running"
else
  echo "❌ PostgreSQL service is not running. Starting..."
  sudo systemctl start postgresql
  sudo systemctl enable postgresql
fi

# Check PostgreSQL user
if sudo -u postgres psql -c "\du" | grep postgres; then
  echo "✅ PostgreSQL admin user exists"
else
  echo "❌ PostgreSQL admin user issue detected"
fi

# Fix PostgreSQL authentication configuration
echo "Updating pg_hba.conf for local authentication..."
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     md5/g' /etc/postgresql/*/main/pg_hba.conf
sudo sed -i 's/local   all             postgres                                peer/local   all             postgres                                md5/g' /etc/postgresql/*/main/pg_hba.conf

# Restart PostgreSQL
echo "Restarting PostgreSQL service..."
sudo systemctl restart postgresql

# Install psycopg2 dependencies
echo "Installing psycopg2 dependencies..."
sudo apt-get install -y python3-dev libpq-dev python3-pip
sudo pip3 install psycopg2-binary

# Verify PostgreSQL connection
echo "Verifying PostgreSQL connection..."
if sudo -u postgres psql -c "SELECT version();"; then
  echo "✅ PostgreSQL connection successful"
else
  echo "❌ PostgreSQL connection failed"
fi

echo "Creating a test user..."
sudo -u postgres psql -c "CREATE USER test_user WITH PASSWORD 'password';" || echo "User may already exist"

echo "==== Script completed ===="
echo "You can now try running your Ansible playbook ag
