# Email Phishing Detection SOC Lab

A containerized Security Operations Center (SOC) lab environment designed to demonstrate email phishing attack detection and monitoring using Wazuh SIEM.

## 🏗️ Architecture

This project simulates a complete email security monitoring scenario with the following components:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Attacker  │───▶│Email Server │───▶│ Wazuh Agent │
│  Container  │    │  (Postfix)  │    │   Monitor   │
└─────────────┘    └─────────────┘    └─────────────┘
                                              │
                                              ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Wazuh     │◀───│   Wazuh     │◀───│   Wazuh     │
│ Dashboard   │    │  Manager    │    │  Indexer    │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 🚀 Components

### 1. **Attacker Container**
- Simulates malicious email sending
- Python-based script that sends phishing emails
- Targets the email server with suspicious content

### 2. **Email Server (Postfix)**
- Full-featured mail server using Postfix
- Configured for domain `example.com`
- Logs all email transactions for monitoring

### 3. **Wazuh Security Stack**
- **Wazuh Agent**: Monitors email server logs in real-time
- **Wazuh Manager**: Central security event processing
- **Wazuh Indexer**: OpenSearch-based data storage
- **Wazuh Dashboard**: Security visualization and alerting

## 📋 Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- Ports 25, 1514, 1515, 5601, and 9200 available

## 🏃‍♂️ Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd /path/to/EmailPhishing
   ```

2. **Start the environment:**
   ```bash
   docker-compose up -d
   ```

3. **Wait for all services to be ready** (approximately 2-3 minutes)

4. **Trigger the attack:**
   ```bash
   docker-compose restart attacker
   ```

5. **Access the Wazuh Dashboard:**
   ```
   http://localhost:5601
   ```

## 🔍 Monitoring & Detection

### Email Logs Location
- **Host Path**: `/var/log/mail/mail.log` (inside email-server container)
- **Shared Volume**: `postfix_logs` (accessible by wazuh-agent)

### Wazuh Configuration
- **Agent Config**: `wazuh/agent/ossec.conf`
- **Log Format**: Syslog
- **Monitored Location**: `/var/log/mail/mail.log`

### Key Detection Points
1. **Email Transmission Logs**: Monitor SMTP connections and email flow
2. **Suspicious Patterns**: Detect unusual sender/recipient patterns
3. **Content Analysis**: Flag emails with malicious indicators
4. **Volume Analysis**: Identify bulk email sending attempts

## 📊 Dashboard Access

Once all containers are running:

- **Wazuh Dashboard**: http://localhost:5601
  - Navigate to Security Events
  - Filter by agent (wazuh-agent)
  - Monitor mail log events

- **OpenSearch API**: http://localhost:9200
  - Direct access to indexed security data

## 🐛 Troubleshooting

### Check Container Status
```bash
docker-compose ps
```

### View Logs
```bash
# Wazuh Agent logs
docker-compose logs wazuh-agent

# Email Server logs
docker-compose logs email-server

# Wazuh Manager logs
docker-compose logs wazuh-manager
```

### Restart Specific Service
```bash
docker-compose restart <service-name>
```

### Access Container Shell
```bash
docker exec -it <container-name> /bin/bash
```

## 🔧 Configuration Files

```
├── docker-compose.yml          # Main orchestration
├── attacker/
│   ├── Dockerfile             # Attacker container build
│   └── send_email.py          # Malicious email script
├── postfix/
│   ├── main.cf                # Postfix configuration
│   ├── mailname               # Mail domain settings
│   └── aliases                # Email aliases
└── wazuh/
    ├── agent/
    │   ├── Dockerfile         # Custom Wazuh agent
    │   └── ossec.conf         # Agent configuration
    ├── dashboard/
    │   └── opensearch_dashboards.yml
    └── indexer/
        └── opensearch.yml     # Search engine config
```

## 🎯 Use Cases

### Educational Scenarios
- **SOC Analyst Training**: Learn to identify email-based threats
- **SIEM Deployment**: Understand Wazuh configuration and management
- **Log Analysis**: Practice security event correlation

### Security Testing
- **Phishing Simulation**: Test email security controls
- **Detection Tuning**: Optimize security rules and alerts
- **Incident Response**: Practice threat hunting workflows

## ⚠️ Security Notes

- **Lab Environment Only**: This setup is for educational purposes
- **No Real Email**: Uses containerized environment only
- **Disabled Security**: Some Wazuh security features disabled for ease of use
- **Local Network**: All traffic stays within Docker network

## 🛡️ Advanced Configuration

### Custom Rules
Add custom detection rules in `wazuh/manager/rules/` (if extended)

### Alert Integration
Configure email/Slack notifications in Wazuh Manager

### Extended Monitoring
- Add more log sources (web servers, firewalls)
- Implement custom decoders for specific log formats
- Create custom dashboards for different security scenarios

## 📚 Learning Resources

- [Wazuh Documentation](https://documentation.wazuh.com/)
- [OpenSearch Documentation](https://opensearch.org/docs/)
- [Postfix Configuration Guide](http://www.postfix.org/documentation.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description

## 📄 License

This project is intended for educational and research purposes. Please use responsibly and in accordance with applicable laws and regulations.

---

**Happy Security Monitoring! 🔒**
