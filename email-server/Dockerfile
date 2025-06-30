FROM debian:bullseye-slim

# Set environment variables for faster builds
ENV DEBIAN_FRONTEND=noninteractive

# Install Postfix and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postfix \
        syslog-ng \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        procps \
        netcat-openbsd && \
    # Install Wazuh agent
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

# Ensure wazuh user exists and set ownership
RUN getent passwd wazuh >/dev/null 2>&1 || adduser --disabled-password --gecos '' wazuh && \
    chown -R wazuh:wazuh /var/ossec

# Copy custom entrypoint script
COPY entrypoint.sh /data/entrypoint.sh
RUN chmod +x /data/entrypoint.sh

# Expose ports
EXPOSE 25 1514

# The entrypoint script will handle both Postfix and Wazuh agent startup
CMD ["/data/entrypoint.sh"] 