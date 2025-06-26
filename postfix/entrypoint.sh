#!/bin/bash
set -e

# Copy aliases file to /etc and generate aliases.db
echo "Setting up Postfix aliases..."
cp /data/aliases /etc/aliases
postalias /etc/aliases

# Start Postfix
echo "Starting Postfix..."
postfix start

# Create log file if it doesn't exist and wait for it
echo "Waiting for mail log file..."
mkdir -p /var/log/mail
touch /var/log/mail/mail.log

# Wait a moment for Postfix to start writing logs
sleep 2

# Tail the log file
echo "Tailing mail log..."
tail -F /var/log/mail/mail.log 