# Email Phishing Detection SOC Lab 🚀

A containerized Security Operations Center (SOC) lab environment designed to demonstrate email phishing attack detection and monitoring using Wazuh SIEM. This lab provides hands-on experience with security monitoring, threat detection, and incident response in a safe, controlled environment.

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

## 🚀 Quick Start

### Prerequisites

- **Docker** (version 20.10 or higher)
- **Docker Compose** (version 2.0 or higher)
- **At least 4GB RAM** available
- **Ports 25, 1514, 1515, 5601, and 9200** available

### Easy Deployment

1. **Clone and navigate to the project:**
   ```bash
   cd /path/to/EmailPhishing
   ```

2. **Start the environment using the management script:**
   ```bash
   ./start.sh start
   ```

3. **Wait for all services to be healthy** (approximately 2-3 minutes)

4. **Trigger the phishing attack:**
   ```bash
   ./start.sh attack
   ```

5. **Access the Wazuh Dashboard:**
   ```
   http://localhost:5601
   ```

## 🎯 Management Commands

The project includes a comprehensive management script (`start.sh`) for easy operation:

```bash
# Start the environment
./start.sh start

# Check service status
./start.sh status

# View logs (all services)
./start.sh logs

# View logs for specific service
./start.sh logs wazuh-agent

# Trigger phishing attack
./start.sh attack

# Stop the environment
./start.sh stop

# Restart the environment
./start.sh restart

# Clean up everything
./start.sh cleanup

# Show help
./start.sh help
```

## 🔍 Components

### 1. **Attacker Container** 🎭
- **Purpose**: Simulates malicious email sending
- **Technology**: Python-based script with retry logic
- **Features**: 
  - Realistic phishing email content
  - Error handling and retry mechanisms
  - Configurable attack scenarios
- **Target**: Sends phishing emails to `user@example.com`

### 2. **Email Server (Postfix)** 📧
- **Purpose**: Full-featured mail server for email processing
- **Configuration**: 
  - Domain: `example.com`
  - SMTP on port 25
  - Comprehensive logging
- **Monitoring**: All email transactions logged for analysis

### 3. **Wazuh Security Stack** 🛡️

#### **Wazuh Agent**
- **Purpose**: Real-time log monitoring and analysis
- **Features**:
  - Custom phishing detection rules
  - Email volume monitoring
  - Suspicious pattern detection
  - Active response capabilities

#### **Wazuh Manager**
- **Purpose**: Central security event processing
- **Features**:
  - Event correlation
  - Alert generation
  - Rule management
  - Active response coordination

#### **Wazuh Indexer (OpenSearch)**
- **Purpose**: Data storage and search
- **Features**:
  - Scalable data storage
  - Fast search capabilities
  - RESTful API access

#### **Wazuh Dashboard**
- **Purpose**: Security visualization and alerting
- **Features**:
  - Real-time security events
  - Custom dashboards
  - Alert management
  - Threat hunting tools

## 🔧 Optimizations Made

### Docker Compose Improvements
- ✅ **Health Checks**: All services now have proper health monitoring
- ✅ **Restart Policies**: Automatic restart on failure (`unless-stopped`)
- ✅ **Resource Limits**: Memory and CPU constraints for stability
- ✅ **Service Dependencies**: Health-based dependency management
- ✅ **Custom Network**: Isolated network for better security
- ✅ **Volume Management**: Proper volume drivers and persistence

### Security Enhancements
- ✅ **Custom Detection Rules**: Phishing-specific alerting
- ✅ **Active Response**: Automated threat response capabilities
- ✅ **Log Analysis**: Enhanced monitoring and correlation
- ✅ **Rootkit Detection**: System integrity monitoring

### Operational Improvements
- ✅ **Management Script**: Easy deployment and operation
- ✅ **Error Handling**: Robust error handling and retry logic
- ✅ **Monitoring**: Comprehensive health and status monitoring
- ✅ **Documentation**: Detailed setup and usage instructions

## 📊 Monitoring & Detection

### Email Logs Location
- **Host Path**: `/var/log/mail/mail.log` (inside email-server container)
- **Shared Volume**: `postfix_logs` (accessible by wazuh-agent)

### Wazuh Configuration
- **Agent Config**: `wazuh/agent/ossec.conf`
- **Log Format**: Syslog
- **Monitored Location**: `/var/log/mail/mail.log`

### Detection Rules
The system includes custom rules for detecting:

1. **Suspicious Sender Domains**: `security@example-bank.com`
2. **Urgency Tactics**: "URGENT Account Suspended" patterns
3. **Suspicious Links**: `example-bank-verify.com` domains
4. **Security Impersonation**: Emails from "security@" addresses
5. **High Volume Attacks**: Bulk email sending detection
6. **SMTP Connections**: Connection monitoring and analysis

### Key Detection Points
- **Email Transmission Logs**: Monitor SMTP connections and email flow
- **Suspicious Patterns**: Detect unusual sender/recipient patterns
- **Content Analysis**: Flag emails with malicious indicators
- **Volume Analysis**: Identify bulk email sending attempts
- **Link Analysis**: Detect suspicious URLs and domains

## 📊 Dashboard Access

Once all containers are running:

### Wazuh Dashboard
- **URL**: http://localhost:5601
- **Features**:
  - Security Events monitoring
  - Agent status and health
  - Custom dashboards
  - Alert management
  - Threat hunting tools

### OpenSearch API
- **URL**: http://localhost:9200
- **Features**:
  - Direct access to indexed security data
  - RESTful API for custom integrations
  - Data export capabilities

## 🐛 Troubleshooting

### Check Container Status
```bash
./start.sh status
# or
docker compose ps
```

### View Service Logs
```bash
# All services
./start.sh logs

# Specific service
./start.sh logs wazuh-agent
./start.sh logs email-server
./start.sh logs wazuh-manager
```

### Common Issues

#### Services Not Starting
```bash
# Check Docker resources
docker system df
docker stats

# Restart services
./start.sh restart
```

#### Health Check Failures
```bash
# Check individual service health
docker compose ps

# View detailed logs
docker compose logs <service-name>
```

#### Port Conflicts
```bash
# Check port usage
netstat -tuln | grep -E ':(25|1514|1515|5601|9200)'

# Stop conflicting services
sudo systemctl stop <conflicting-service>
```

### Access Container Shell
```bash
docker exec -it <container-name> /bin/bash
```

## 🔧 Configuration Files

```
├── docker-compose.yml          # Main orchestration (optimized)
├── start.sh                    # Management script
├── attacker/
│   ├── Dockerfile             # Attacker container build
│   └── send_email.py          # Enhanced phishing script
├── postfix/
│   ├── main.cf                # Postfix configuration
│   ├── mailname               # Mail domain settings
│   └── aliases                # Email aliases
└── wazuh/
    ├── agent/
    │   ├── Dockerfile         # Custom Wazuh agent
    │   └── ossec.conf         # Enhanced agent configuration
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
- **Incident Response**: Develop threat hunting skills

### Security Testing
- **Phishing Simulation**: Test email security controls
- **Detection Tuning**: Optimize security rules and alerts
- **Incident Response**: Practice threat hunting workflows
- **Security Tool Evaluation**: Test SIEM capabilities

### Research & Development
- **Threat Intelligence**: Develop and test detection rules
- **Security Automation**: Implement active response mechanisms
- **Performance Testing**: Evaluate SIEM performance under load
- **Integration Testing**: Test security tool integrations

## ⚠️ Security Notes

- **Lab Environment Only**: This setup is for educational purposes
- **No Real Email**: Uses containerized environment only
- **Disabled Security**: Some Wazuh security features disabled for ease of use
- **Local Network**: All traffic stays within Docker network
- **No Production Use**: Not suitable for production environments

## 🛡️ Advanced Configuration

### Custom Rules
Add custom detection rules in `wazuh/agent/ossec.conf`:

```xml
<rule>
    <id>100008</id>
    <level>13</level>
    <if_sid>0</if_sid>
    <match>your-custom-pattern</match>
    <description>Custom detection rule</description>
</rule>
```

### Alert Integration
Configure email/Slack notifications in Wazuh Manager:

```bash
# Access Wazuh Manager configuration
docker exec -it wazuh-manager /bin/bash
```

### Extended Monitoring
- Add more log sources (web servers, firewalls)
- Implement custom decoders for specific log formats
- Create custom dashboards for different security scenarios
- Integrate with external threat intelligence feeds

## 📚 Learning Resources

- [Wazuh Documentation](https://documentation.wazuh.com/)
- [OpenSearch Documentation](https://opensearch.org/docs/)
- [Postfix Configuration Guide](http://www.postfix.org/documentation.html)
- [Docker Compose Best Practices](https://docs.docker.com/compose/production/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description
4. Ensure all tests pass
5. Update documentation as needed

## 📄 License

This project is intended for educational and research purposes. Please use responsibly and in accordance with applicable laws and regulations.

---

**Happy Security Monitoring! 🔒**

*For questions or issues, please check the troubleshooting section or create an issue in the repository.*
