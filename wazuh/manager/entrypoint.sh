#!/bin/bash
set -e

# Copy filebeat.yml to a writeable location and set correct ownership
cp /mounted/filebeat.yml /etc/filebeat/filebeat.yml
chown root:root /etc/filebeat/filebeat.yml
chmod 600 /etc/filebeat/filebeat.yml

# Start the original entrypoint (assume default CMD)
exec /init 