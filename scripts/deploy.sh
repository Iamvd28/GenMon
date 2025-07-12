#!/bin/bash

# deploy.sh - Deployment script for GenMon4 Backend
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="genmon4-backend"
DOCKER_COMPOSE_FILE="docker-compose.yml"
DOCKER_COMPOSE_PROD_FILE="docker-compose.prod.yml"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi
    
    log_success "All dependencies are installed"
}

check_environment() {
    log_info "Checking environment variables..."
    
    required_vars=("JWT_SECRET" "JUDGE0_API_KEY")
    missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        log_error "Missing required environment variables: ${missing_vars[*]}"
        log_info "Please set them in your .env file or environment"
        exit 1
    fi
    
    log_success "Environment variables are configured"
}

build_image() {
    log_info "Building Docker image..."
    
    if docker build -t $PROJECT_NAME .; then
        log_success "Docker image built successfully"
    else
        log_error "Failed to build Docker image"
        exit 1
    fi
}

deploy_development() {
    log_info "Deploying in development mode..."
    
    if docker-compose -f $DOCKER_COMPOSE_FILE up -d; then
        log_success "Development deployment completed"
        log_info "Services are starting up..."
        log_info "Backend API: http://localhost:3000"
        log_info "MongoDB Express: http://localhost:8081"
        log_info "Redis Commander: http://localhost:8082"
    else
        log_error "Development deployment failed"
        exit 1
    fi
}

deploy_production() {
    log_info "Deploying in production mode..."
    
    if docker-compose -f $DOCKER_COMPOSE_PROD_FILE up -d; then
        log_success "Production deployment completed"
        log_info "Services are starting up..."
        log_info "Backend API: http://localhost:3000"
    else
        log_error "Production deployment failed"
        exit 1
    fi
}

deploy_with_proxy() {
    log_info "Deploying with Nginx reverse proxy..."
    
    if docker-compose -f $DOCKER_COMPOSE_PROD_FILE --profile with-proxy up -d; then
        log_success "Production deployment with proxy completed"
        log_info "Services are starting up..."
        log_info "Backend API: https://localhost"
    else
        log_error "Production deployment with proxy failed"
        exit 1
    fi
}

check_health() {
    log_info "Checking service health..."
    
    # Wait for services to start
    sleep 10
    
    # Check backend health
    if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
        log_success "Backend service is healthy"
    else
        log_warning "Backend service health check failed"
    fi
    
    # Check MongoDB
    if docker-compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        log_success "MongoDB is healthy"
    else
        log_warning "MongoDB health check failed"
    fi
    
    # Check Redis
    if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
        log_success "Redis is healthy"
    else
        log_warning "Redis health check failed"
    fi
}

show_logs() {
    log_info "Showing service logs..."
    docker-compose logs -f
}

stop_services() {
    log_info "Stopping services..."
    
    if docker-compose down; then
        log_success "Services stopped successfully"
    else
        log_error "Failed to stop services"
        exit 1
    fi
}

cleanup() {
    log_info "Cleaning up..."
    
    # Remove unused images
    docker image prune -f
    
    # Remove unused volumes
    docker volume prune -f
    
    log_success "Cleanup completed"
}

show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  dev         Deploy in development mode"
    echo "  prod        Deploy in production mode"
    echo "  proxy       Deploy in production mode with Nginx proxy"
    echo "  build       Build Docker image only"
    echo "  health      Check service health"
    echo "  logs        Show service logs"
    echo "  stop        Stop all services"
    echo "  cleanup     Clean up unused Docker resources"
    echo "  help        Show this help message"
    echo ""
    echo "Environment:"
    echo "  JWT_SECRET          Required: JWT signing secret"
    echo "  JUDGE0_API_KEY      Required: Judge0 API key"
    echo "  MONGO_ROOT_USERNAME Optional: MongoDB root username (default: admin)"
    echo "  MONGO_ROOT_PASSWORD Optional: MongoDB root password (default: password)"
}

# Main script
case "${1:-help}" in
    "dev")
        check_dependencies
        check_environment
        build_image
        deploy_development
        check_health
        ;;
    "prod")
        check_dependencies
        check_environment
        build_image
        deploy_production
        check_health
        ;;
    "proxy")
        check_dependencies
        check_environment
        build_image
        deploy_with_proxy
        check_health
        ;;
    "build")
        check_dependencies
        build_image
        ;;
    "health")
        check_health
        ;;
    "logs")
        show_logs
        ;;
    "stop")
        stop_services
        ;;
    "cleanup")
        cleanup
        ;;
    "help"|*)
        show_help
        ;;
esac 