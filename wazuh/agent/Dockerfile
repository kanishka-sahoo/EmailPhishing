FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl gnupg lsb-release && \
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add - && \
    echo "deb https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && \
    apt-get install -y wazuh-agent && \
    ls -l /var/ossec/bin/ && \
    if [ ! -f /var/ossec/bin/wazuh-control ]; then echo "wazuh-control not found!"; exit 1; fi && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy custom config if present
COPY ossec.conf /var/ossec/etc/ossec.conf

# Start agent
CMD ["/var/ossec/bin/wazuh-control", "start"]
