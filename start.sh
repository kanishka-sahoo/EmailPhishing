#!/bin/bash

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
    
    # Check if ports are available
    local ports=(25 1514 1515 5601 9200)
    for port in "${ports[@]}"; do
        if netstat -tuln | grep -q ":$port "; then
            print_warning "Port $port is already in use. Make sure it's not needed by another service."
        fi
    done
    
    print_success "Prerequisites check completed"
}

# Function to start the environment
start_environment() {
    print_status "Starting SOC lab environment..."
    
    # Build and start services
    docker compose up -d --build
    
    print_success "Services started successfully"
    print_status "Waiting for services to be healthy..."
    
    # Wait for services to be ready
    local max_wait=300  # 5 minutes
    local wait_time=0
    
    while [ $wait_time -lt $max_wait ]; do
        if docker compose ps | grep -q "healthy"; then
            print_success "All services are healthy!"
            break
        fi
        
        sleep 10
        wait_time=$((wait_time + 10))
        print_status "Waiting for services to be ready... ($wait_time/$max_wait seconds)"
    done
    
    if [ $wait_time -ge $max_wait ]; then
        print_warning "Some services may still be starting up. Check with 'docker compose ps'"
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
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start          # Start the environment"
    echo "  $0 logs wazuh-agent  # Show Wazuh agent logs"
    echo "  $0 attack         # Trigger phishing attack"
}

# Main script logic
case "${1:-help}" in
    start)
        check_prerequisites
        start_environment
        show_status
        ;;
    stop)
        stop_environment
        ;;
    restart)
        stop_environment
        sleep 2
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