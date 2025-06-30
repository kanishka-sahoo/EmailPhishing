#!/bin/bash

# Email Server with Wazuh Agent Integration
# This script starts both Postfix and Wazuh agent in the same container

set -e

# Function to print colored output
print_status() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# Function to configure Postfix
configure_postfix() {
    print_status "Configuring Postfix..."
    
    # Set mail domain
    echo "${maildomain:-example.com}" > /etc/mailname
    
    # Create mail directory and user
    mkdir -p /var/mail/vhosts/${maildomain:-example.com}
    useradd -m -s /bin/bash user || true
    mkdir -p /home/user/Maildir
    chown -R user:user /home/user/Maildir
    
    # Skip aliases db generation to avoid permission errors
    print_status "Skipping Postfix aliases db generation (handled on host)"
    
    print_success "Postfix configured"
}

# Function to start Wazuh agent
start_wazuh_agent() {
    print_status "Starting Wazuh agent..."
    
    # Wait for Wazuh manager to be ready
    print_status "Waiting for Wazuh manager to be ready..."
    until nc -z wazuh-manager 1514; do
        echo "Waiting for wazuh-manager:1514..."
        sleep 5
    done
    print_success "Wazuh manager is ready"
    
    # Start Wazuh agent
    /var/ossec/bin/wazuh-control start
    
    # Check if agent started successfully
    if pgrep wazuh-agentd > /dev/null; then
        print_success "Wazuh agent started successfully"
    else
        print_error "Failed to start Wazuh agent"
        exit 1
    fi
}

# Function to stop Wazuh agent
stop_wazuh_agent() {
    print_status "Stopping Wazuh agent..."
    /var/ossec/bin/wazuh-control stop || true
}

# Trap to ensure Wazuh agent is stopped on exit
trap stop_wazuh_agent EXIT

# Configure Postfix
configure_postfix

# Start Wazuh agent
start_wazuh_agent

# Start Postfix
print_status "Starting Postfix mail server..."
postfix start

# Start syslog-ng for logging
print_status "Starting syslog-ng..."
syslog-ng -F &

# Keep container running and monitor processes
print_success "Email server with Wazuh agent is ready"

# Wait for both Postfix and Wazuh agent to stay alive
while true; do
    # Check if Postfix is still running
    if ! pgrep master > /dev/null; then
        print_error "Postfix master process died"
        exit 1
    fi
    
    # Check if Wazuh agent is still running
    if ! pgrep wazuh-agentd > /dev/null; then
        print_error "Wazuh agent process died"
        exit 1
    fi
    
    sleep 30
done 