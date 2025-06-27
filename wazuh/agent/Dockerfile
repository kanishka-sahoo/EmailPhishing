FROM debian:bullseye-slim

# Set environment variables for faster builds
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies in a single RUN command to reduce layers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        lsb-release \
        ca-certificates && \
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add - && \
    echo "deb https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends wazuh-agent && \
    # Verify installation
    ls -l /var/ossec/bin/ && \
    if [ ! -f /var/ossec/bin/wazuh-control ]; then echo "wazuh-control not found!"; exit 1; fi && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy custom config if present
COPY ossec.conf /var/ossec/etc/ossec.conf

# Ensure wazuh user exists and set ownership
RUN getent passwd wazuh >/dev/null 2>&1 || adduser --disabled-password --gecos '' wazuh && \
    chown -R wazuh:wazuh /var/ossec

# Start agent as root (will handle user switching internally)
CMD ["/var/ossec/bin/wazuh-control", "start"]
