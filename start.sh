#!/bin/bash

# NOTE: Authentication is ENABLED for Wazuh Dashboard and OpenSearch.
# - The indexer security plugin is enabled (DISABLE_SECURITY_PLUGIN is removed)
# - The dashboard will prompt for login
# - The admin password is set to 'password' automatically on startup
#
# If you want to change the password, update the PASSWORD variable below.

PASSWORD='password'
ADMIN_HASH='$2y$12$Uu6dGm89FUVha12sMM4JUeeLymBGItttY3bEoRHXvnUjDzt2QNUMS'
INTERNAL_USERS=internal_users.yml

# Email Phishing Detection SOC Lab - Startup Script
# This script helps deploy and manage the SOC lab environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show startup tips
show_startup_tips() {
    echo ""
    print_status "Startup Optimization Tips:"
    echo "  • Use 'docker system prune -f' to clean up unused images/containers"
    echo "  • Ensure sufficient disk space and memory"
    echo "  • Close other resource-intensive applications"
    echo "  • Use 'docker compose pull' to pre-download images"
    echo "  • Consider using 'docker buildx' for faster builds"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Docker Compose is available
    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    
    # Check Docker daemon is running
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    
    # Check if ports are available
    local ports=(25 1514 1515 5601 9200)
    for port in "${ports[@]}"; do
        if netstat -tuln | grep -q ":$port "; then
            print_warning "Port $port is already in use. Make sure it's not needed by another service."
        fi
    done
    
    # Check available disk space (at least 2GB)
    local available_space=$(df . | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 2097152 ]; then  # 2GB in KB
        print_warning "Low disk space available. Consider freeing up space."
    fi
    
    # Check available memory (at least 4GB)
    local available_memory=$(free -m | awk 'NR==2 {print $7}')
    if [ "$available_memory" -lt 4096 ]; then
        print_warning "Low memory available. Consider closing other applications."
    fi
    
    print_success "Prerequisites check completed"
}

# Function to check service health more efficiently
check_services_health() {
    local healthy_count=0
    local total_services=6  # attacker, email-server, wazuh-indexer, wazuh-manager, wazuh-agent, wazuh-dashboard

    # Use docker compose ps --format to count healthy containers robustly
    healthy_count=$(docker compose ps --format '{{.Service}} {{.Health}}' | grep -c 'healthy')
    echo $healthy_count
}

# Function to start the environment
start_environment() {
    print_status "Starting SOC lab environment..."

    local total_services=6  # attacker, email-server, wazuh-indexer, wazuh-manager, wazuh-agent, wazuh-dashboard

    # Build and start services
    docker compose up -d --build

    print_success "Services started successfully"
    print_status "Waiting for services to be healthy..."

    # Wait for services to be ready
    local max_wait=90  # 3 minutes (reduced from 5 minutes)
    local wait_time=0
    local last_healthy_count=0

    while [ $wait_time -lt $max_wait ]; do
        local current_healthy=$(check_services_health)
        current_healthy=${current_healthy:-0}
        last_healthy_count=${last_healthy_count:-0}
        if [ "$current_healthy" -ne "$last_healthy_count" ]; then
            print_status "Services healthy: $current_healthy/$total_services"
            last_healthy_count=$current_healthy
        fi
        if [ "$current_healthy" -eq "$total_services" ]; then
            print_success "All services are healthy!"
            break
        fi
        sleep 5  # Reduced from 10s to 5s
        wait_time=$((wait_time + 5))
        # Show progress every 30 seconds
        if [ $((wait_time % 30)) -eq 0 ]; then
            print_status "Waiting for services to be ready... ($wait_time/$max_wait seconds) - $current_healthy/$total_services healthy"
        fi
    done

    # Wait for OpenSearch Dashboards API to be ready
    print_status "Waiting for OpenSearch Dashboards API to be ready..."
    for i in {1..30}; do
      if curl -s -o /dev/null -w "%{http_code}" "http://localhost:5601/api/status" | grep -q "200"; then
        print_success "OpenSearch Dashboards API is ready."
        break
      fi
      sleep 2
    done

    # Check if wazuh-alerts-* data view exists
    print_status "Checking if wazuh-alerts-* data view exists..."
    if ! curl -s -X GET "http://localhost:5601/api/data_views/data_view/wazuh-alerts-*" -H 'kbn-xsrf: true' | grep -q '"id":"wazuh-alerts-*"'; then
      print_status "Creating wazuh-alerts-* data view with @timestamp as time field..."
      curl -s -X POST "http://localhost:5601/api/data_views/data_view" \
        -H 'kbn-xsrf: true' \
        -H 'Content-Type: application/json' \
        -d '{"data_view":{"title":"wazuh-alerts-*","name":"wazuh-alerts-*","timeFieldName":"@timestamp"}}'
    else
      print_status "wazuh-alerts-* data view already exists."
    fi

    # Set wazuh-alerts-* as the default data view
    print_status "Setting wazuh-alerts-* as the default data view..."
    curl -s -X POST "http://localhost:5601/api/kibana/settings/defaultIndex" \
      -H 'kbn-xsrf: true' \
      -H 'Content-Type: application/json' \
      -d '{"value":"wazuh-alerts-*"}'

    # After starting services, update admin password if indexer is running
    if docker compose ps | grep -q wazuh-indexer; then
        update_admin_password
    fi
}

# Function to trigger the attack
trigger_attack() {
    print_status "Triggering phishing email attack..."
    docker compose restart attacker
    print_success "Attack simulation triggered"
}

# Function to show status
show_status() {
    print_status "Current service status:"
    docker compose ps
    
    echo ""
    print_status "Service URLs:"
    echo "  - Wazuh Dashboard: http://localhost:5601"
    echo "  - Wazuh API: https://localhost:55000"
    echo "  - OpenSearch API: http://localhost:9200"
    echo "  - SMTP Server: localhost:25"
}

# Function to show logs
show_logs() {
    local service=${1:-"all"}
    
    if [ "$service" = "all" ]; then
        print_status "Showing logs for all services (Ctrl+C to exit):"
        docker compose logs -f
    else
        print_status "Showing logs for $service (Ctrl+C to exit):"
        docker compose logs -f "$service"
    fi
}

# Function to stop the environment
stop_environment() {
    print_status "Stopping SOC lab environment..."
    docker compose down
    print_success "Environment stopped"
}

# Function to clean up
cleanup() {
    print_status "Cleaning up environment..."
    docker compose down -v --remove-orphans
    docker system prune -f
    print_status "Fixing permissions for wazuh/manager/filebeat.yml..."
    sudo chown $USER:$USER wazuh/manager/filebeat.yml
    sudo chmod 644 wazuh/manager/filebeat.yml
    print_success "Permissions for wazuh/manager/filebeat.yml set to $USER:$USER and 644."
    print_success "Cleanup completed"
}

# Function to show help
show_help() {
    echo "Email Phishing Detection SOC Lab - Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start       Start the SOC lab environment"
    echo "  stop        Stop the SOC lab environment"
    echo "  restart     Restart the SOC lab environment"
    echo "  status      Show current service status"
    echo "  logs [SERVICE] Show logs (all services or specific service)"
    echo "  attack      Trigger the phishing email attack"
    echo "  cleanup     Stop and clean up all containers and volumes"
    echo "  optimize    Optimize the environment for faster startup"
    echo "  init        Initialize OpenSearch compatibility and Filebeat log dir, restart Wazuh Manager"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start          # Start the environment"
    echo "  $0 logs wazuh-agent  # Show Wazuh agent logs"
    echo "  $0 attack         # Trigger phishing attack"
}

# Function to update admin password
update_admin_password() {
    # Check if security plugin is disabled in the running container
    if docker compose exec wazuh-indexer printenv | grep -q 'DISABLE_SECURITY_PLUGIN=true'; then
        print_status "OpenSearch security plugin is disabled. Skipping admin password update."
        return
    fi
    print_status "Updating OpenSearch admin password..."
    docker cp wazuh-indexer:/usr/share/opensearch/plugins/opensearch-security/securityconfig/internal_users.yml $INTERNAL_USERS
    sed -i "/^admin:/,/^  description:/s/^  hash: .*/  hash: \"$ADMIN_HASH\"/" $INTERNAL_USERS
    docker cp $INTERNAL_USERS wazuh-indexer:/usr/share/opensearch/plugins/opensearch-security/securityconfig/internal_users.yml
    docker exec wazuh-indexer bash -c '
      export INSTALLATION_DIR=/usr/share/opensearch
      export JAVA_HOME=$INSTALLATION_DIR/jdk
      bash /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
        -cd /usr/share/opensearch/plugins/opensearch-security/securityconfig/ \
        -nhnv \
        -cacert $INSTALLATION_DIR/config/root-ca.pem \
        -cert $INSTALLATION_DIR/config/kirk.pem \
        -key $INSTALLATION_DIR/config/kirk-key.pem \
        -p 9200 -icl
    '
    print_success "Admin password updated. Use admin:$PASSWORD to log in."
}

# Function to optimize environment
optimize_environment() {
    print_status "Optimizing environment for faster startup..."
    
    # Pre-download images
    print_status "Pre-downloading Docker images..."
    docker compose pull
    
    # Clean up unused resources
    print_status "Cleaning up unused Docker resources..."
    docker system prune -f
    
    print_success "Environment optimization completed"
}

# Trap for graceful shutdown
trap 'print_status "Gracefully stopping SOC lab environment..."; docker compose down; print_success "Environment stopped"; exit 0' SIGINT SIGTERM

# Function to fix filebeat.yml permissions
fix_filebeat_permissions() {
    local filebeat_yml="wazuh/manager/filebeat.yml"
    if [ -f "$filebeat_yml" ]; then
        print_status "Fixing permissions for $filebeat_yml (root:root, 644)"
        sudo chown root:root "$filebeat_yml" 2>/dev/null
        sudo chmod 644 "$filebeat_yml"
    else
        print_warning "$filebeat_yml not found, skipping permission fix."
    fi
}

# Main script logic
case "${1:-help}" in
    start)
        check_prerequisites
        fix_filebeat_permissions
        start_environment
        show_status
        show_startup_tips
        # Call init logic after starting environment
        print_status "Running post-start initialization (OpenSearch compatibility, Filebeat log dir, restart Wazuh Manager)..."
        curl -sf -X PUT "http://localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d '{"persistent": {"compatibility": {"override_main_response_version": true}}}' && print_success "OpenSearch compatibility set."
        print_status "Ensuring /var/log/filebeat exists in wazuh-manager container..."
        docker compose exec wazuh-manager mkdir -p /var/log/filebeat && print_success "/var/log/filebeat created."
        print_status "Restarting wazuh-manager container..."
        docker compose restart wazuh-manager && print_success "wazuh-manager restarted."
        ;;
    stop)
        stop_environment
        ;;
    restart)
        stop_environment
        sleep 2
        fix_filebeat_permissions
        start_environment
        show_status
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    attack)
        trigger_attack
        ;;
    cleanup)
        cleanup
        ;;
    optimize)
        optimize_environment
        ;;
    init)
        print_status "Initializing SOC lab environment (OpenSearch compatibility, Filebeat log dir, restart Wazuh Manager)..."
        print_status "Setting OpenSearch compatibility.override_main_response_version..."
        curl -sf -X PUT "http://localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d '{"persistent": {"compatibility": {"override_main_response_version": true}}}' && print_success "OpenSearch compatibility set."
        print_status "Ensuring /var/log/filebeat exists in wazuh-manager container..."
        docker compose exec wazuh-manager mkdir -p /var/log/filebeat && print_success "/var/log/filebeat created."
        print_status "Restarting wazuh-manager container..."
        docker compose restart wazuh-manager && print_success "wazuh-manager restarted."
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac 