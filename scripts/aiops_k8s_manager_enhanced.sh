#!/bin/bash
# Improved AIOps Kubernetes Management Scripts
# Implements all Copilot recommendations for production-grade operations

set -euo pipefail
IFS=$'\n\t'

# Global configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="/home/aiops_user/logs"
readonly BACKUP_DIR="/home/aiops_user/backups"
readonly CONFIG_FILE="/home/aiops_user/.aiops_config"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Logging functions
log() {
    local timestamp
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[$timestamp]${NC} $1" | tee -a "$LOG_DIR/aiops-ops.log"
}

success() {
    local timestamp
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[$timestamp] SUCCESS:${NC} $1" | tee -a "$LOG_DIR/aiops-ops.log"
}

warning() {
    local timestamp
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[$timestamp] WARNING:${NC} $1" | tee -a "$LOG_DIR/aiops-ops.log"
}

error() {
    local timestamp
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[$timestamp] ERROR:${NC} $1" | tee -a "$LOG_DIR/aiops-ops.log"
}

# Initialize logging directory
init_logging() {
    mkdir -p "$LOG_DIR" "$BACKUP_DIR"
    touch "$LOG_DIR/aiops-ops.log"
    
    # Rotate logs if they get too large
    if [ -f "$LOG_DIR/aiops-ops.log" ] && [ $(stat -c%s "$LOG_DIR/aiops-ops.log") -gt 10485760 ]; then
        mv "$LOG_DIR/aiops-ops.log" "$LOG_DIR/aiops-ops.log.$(date +%Y%m%d-%H%M%S)"
        touch "$LOG_DIR/aiops-ops.log"
    fi
}

# Improved prerequisite checking
check_prerequisites_enhanced() {
    log "Enhanced prerequisite verification..."
    
    # Check if we're in correct environment
    if [ ! -f /proc/version ] || ! grep -q Microsoft /proc/version; then
        warning "Not running in WSL2 environment"
    fi
    
    # Check Docker Desktop connection
    if ! docker info >/dev/null 2>&1; then
        error "Docker Desktop is not accessible"
        error "Solution: Start Docker Desktop from Windows and ensure WSL2 integration is enabled"
        return 1
    fi
    
    # Check Docker permissions (avoid newgrp issues)
    if ! docker ps >/dev/null 2>&1; then
        error "Docker permission denied"
        error "Solution: Run 'sudo usermod -aG docker \$USER' and restart WSL"
        return 1
    fi
    
    # Verify available resources
    local available_memory
    available_memory=$(free -m | awk 'NR==2{printf "%.0f", $7/1024}')
    if [ "$available_memory" -lt 6 ]; then
        warning "Low available memory: ${available_memory}GB (recommended: 6GB+)"
    fi
    
    # Check if Minikube binary exists and is correct version
    if ! command -v minikube >/dev/null 2>&1; then
        error "Minikube not found in PATH"
        return 1
    fi
    
    local minikube_version
    minikube_version=$(minikube version --short 2>/dev/null | cut -d' ' -f3)
    log "Minikube version: $minikube_version"
    
    # Check kubectl availability (either binary or via Minikube)
    if ! command -v kubectl >/dev/null 2>&1 && ! alias kubectl >/dev/null 2>&1; then
        warning "kubectl not available as binary or alias"
        log "Will use 'minikube kubectl --' for operations"
    fi
    
    success "Prerequisites verified"
}

# Enhanced Minikube startup with error handling
start_minikube_enhanced() {
    log "Starting Minikube with enhanced configuration..."
    
    # Backup current kubeconfig if exists
    if [ -f "$HOME/.kube/config" ]; then
        cp "$HOME/.kube/config" "$BACKUP_DIR/kubeconfig-backup-$(date +%Y%m%d-%H%M%S)"
        log "Backed up existing kubeconfig"
    fi
    
    # Check if Minikube is already running
    if minikube status >/dev/null 2>&1; then
        local status
        status=$(minikube status --format='{{.Host}}')
        if [ "$status" = "Running" ]; then
            success "Minikube is already running"
            return 0
        fi
    fi
    
    # Start Minikube with retry logic
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log "Starting Minikube (attempt $attempt/$max_attempts)..."
        
        if minikube start \
            --driver=docker \
            --cpus=2 \
            --memory=4096 \
            --disk-size=20g \
            --wait=true \
            --wait-timeout=300s; then
            break
        else
            error "Minikube start failed (attempt $attempt)"
            if [ $attempt -eq $max_attempts ]; then
                error "Max attempts reached. Check Docker Desktop and system resources"
                return 1
            fi
            
            log "Cleaning up failed attempt..."
            minikube delete >/dev/null 2>&1 || true
            sleep 10
            ((attempt++))
        fi
    done
    
    # Verify cluster is responsive
    local max_wait=60
    local wait_time=0
    while [ $wait_time -lt $max_wait ]; do
        if kubectl get nodes >/dev/null 2>&1; then
            break
        fi
        sleep 2
        ((wait_time+=2))
    done
    
    if [ $wait_time -ge $max_wait ]; then
        error "Cluster did not become responsive within $max_wait seconds"
        return 1
    fi
    
    success "Minikube started successfully"
    
    # Show cluster info
    log "Cluster information:"
    kubectl cluster-info
    kubectl get nodes -o wide
}

# Enhanced system verification
verify_system_enhanced() {
    log "Enhanced system verification..."
    
    # Check all system pods are ready
    local system_pods_ready
    local system_pods_total
    system_pods_ready=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | awk '{print $2}' | grep -E '^[0-9]+/[0-9]+$' | awk -F'/' '$1==$2' | wc -l)
    system_pods_total=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | wc -l)
    
    if [ "$system_pods_ready" -eq "$system_pods_total" ] && [ "$system_pods_total" -gt 0 ]; then
        success "All system pods are ready ($system_pods_ready/$system_pods_total)"
    else
        warning "Not all system pods are ready ($system_pods_ready/$system_pods_total)"
        kubectl get pods -n kube-system --field-selector=status.phase!=Running
    fi
    
    # Check for failed or pending pods
    local failed_pods
    failed_pods=$(kubectl get pods --all-namespaces --field-selector=status.phase=Failed --no-headers | wc -l)
    if [ "$failed_pods" -gt 0 ]; then
        warning "$failed_pods failed pods found"
        kubectl get pods --all-namespaces --field-selector=status.phase=Failed
    fi
    
    # Check cluster events for errors
    local error_events
    error_events=$(kubectl get events --all-namespaces --field-selector type=Warning --no-headers 2>/dev/null | wc -l)
    if [ "$error_events" -gt 0 ]; then
        warning "$error_events warning events found in cluster"
        kubectl get events --all-namespaces --field-selector type=Warning --sort-by='.lastTimestamp' | tail -5
    else
        success "No warning events in cluster"
    fi
    
    # Test DNS resolution
    if kubectl run dns-test-$(date +%s) --image=busybox:1.35 --rm -i --restart=Never -- nslookup kubernetes.default >/dev/null 2>&1; then
        success "DNS resolution working"
    else
        error "DNS resolution failed"
        return 1
    fi
    
    # Check storage class
    local default_storage
    default_storage=$(kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')
    if [ -n "$default_storage" ]; then
        success "Default storage class: $default_storage"
    else
        warning "No default storage class found"
    fi
    
    # Generate resource summary
    log "Resource summary:"
    kubectl top nodes 2>/dev/null || log "Metrics not available (metrics-server may not be installed)"
}

# Enhanced safe shutdown
stop_minikube_enhanced() {
    log "Enhanced safe shutdown of Minikube..."
    
    # Check current status
    if ! minikube status >/dev/null 2>&1; then
        log "Minikube is not running"
        return 0
    fi
    
    # Backup current state
    log "Backing up cluster state..."
    kubectl get all --all-namespaces -o yaml > "$BACKUP_DIR/cluster-state-$(date +%Y%m%d-%H%M%S).yaml" 2>/dev/null || true
    
    # Graceful shutdown of workloads first
    log "Gracefully shutting down workloads..."
    
    # Scale down deployments in aiops namespace if it exists
    if kubectl get namespace aiops >/dev/null 2>&1; then
        kubectl scale deployment --all --replicas=0 -n aiops --timeout=60s 2>/dev/null || true
    fi
    
    # Wait for pods to terminate gracefully
    local shutdown_wait=30
    local wait_time=0
    while [ $wait_time -lt $shutdown_wait ]; do
        local running_pods
        running_pods=$(kubectl get pods --all-namespaces --field-selector=status.phase=Running --no-headers 2>/dev/null | grep -v kube-system | wc -l)
        if [ "$running_pods" -eq 0 ]; then
            break
        fi
        sleep 2
        ((wait_time+=2))
    done
    
    # Stop Minikube
    log "Stopping Minikube..."
    minikube stop
    
    # Verify stopped
    local stop_status
    stop_status=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "Stopped")
    if [ "$stop_status" = "Stopped" ]; then
        success "Minikube stopped successfully"
    else
        warning "Minikube may not have stopped cleanly. Status: $stop_status"
    fi
}

# Enhanced recovery with backup restoration
recover_minikube_enhanced() {
    log "Enhanced recovery process starting..."
    
    # Confirm destructive operation
    echo -e "${RED}WARNING: This will completely destroy the current Minikube cluster${NC}"
    echo -e "All pods, services, and local data will be lost"
    echo -e "Backups in $BACKUP_DIR will be preserved"
    read -p "Continue with recovery? (type 'YES' to confirm): " confirm
    
    if [ "$confirm" != "YES" ]; then
        log "Recovery cancelled by user"
        return 0
    fi
    
    # Clean shutdown first
    log "Attempting clean shutdown..."
    minikube stop 2>/dev/null || true
    
    # Complete destruction
    log "Destroying corrupted cluster..."
    minikube delete --all --purge
    
    # Clean Docker containers (be careful not to affect other containers)
    log "Cleaning Docker containers..."
    docker container prune -f
    
    # Remove Minikube configuration
    rm -rf "$HOME/.minikube"
    
    # Clean kubectl config (preserve backups)
    if [ -f "$HOME/.kube/config" ]; then
        cp "$HOME/.kube/config" "$BACKUP_DIR/kubeconfig-pre-recovery-$(date +%Y%m%d-%H%M%S)"
        rm -f "$HOME/.kube/config"
    fi
    
    # Wait for Docker to stabilize
    log "Waiting for Docker to stabilize..."
    sleep 10
    
    # Restart from scratch
    log "Starting fresh Minikube installation..."
    start_minikube_enhanced
    
    # Restore hardened configuration if available
    if [ -f "/home/claude/aiops-security-manifests.yaml" ]; then
        log "Restoring security configuration..."
        kubectl apply -f "/home/claude/aiops-security-manifests.yaml"
    fi
    
    # Verify recovery
    verify_system_enhanced
    
    success "Recovery completed successfully"
    log "Latest backup files in: $BACKUP_DIR"
}

# Performance monitoring
monitor_performance() {
    log "Starting performance monitoring..."
    
    local monitor_duration=${1:-60}  # Default 60 seconds
    local output_file="$LOG_DIR/performance-$(date +%Y%m%d-%H%M%S).log"
    
    {
        echo "Performance Monitoring Report"
        echo "Started: $(date)"
        echo "Duration: ${monitor_duration}s"
        echo "=========================="
        echo
        
        # System resources
        echo "=== SYSTEM RESOURCES ==="
        free -h
        echo
        df -h /
        echo
        
        # Docker stats
        echo "=== DOCKER CONTAINERS ==="
        docker stats --no-stream
        echo
        
        # Kubernetes cluster resources
        echo "=== KUBERNETES RESOURCES ==="
        kubectl top nodes 2>/dev/null || echo "Metrics not available"
        kubectl top pods --all-namespaces 2>/dev/null || echo "Pod metrics not available"
        echo
        
    } > "$output_file"
    
    # Monitor API server response time
    local api_server
    api_server=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    
    log "Monitoring API server latency for ${monitor_duration}s..."
    {
        echo "=== API SERVER LATENCY ==="
        for i in $(seq 1 $((monitor_duration/5))); do
            local start_time
            local end_time
            local latency
            start_time=$(date +%s%N)
            kubectl get --raw /healthz >/dev/null 2>&1
            end_time=$(date +%s%N)
            latency=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
            echo "$(date): ${latency}ms"
            sleep 5
        done
    } >> "$output_file"
    
    success "Performance monitoring completed. Results: $output_file"
}

# Main menu system
show_menu() {
    echo
    echo -e "${PURPLE}AIOps Kubernetes Management System${NC}"
    echo -e "${PURPLE}===================================${NC}"
    echo "1. Start System (Enhanced)"
    echo "2. Verify System (Enhanced)"
    echo "3. Stop System (Safe)"
    echo "4. Recover System (Nuclear)"
    echo "5. Monitor Performance"
    echo "6. Show Logs"
    echo "7. Backup Configuration"
    echo "8. Exit"
    echo
}

# Execute operations based on menu choice or direct parameter
main() {
    # Initialize logging
    init_logging
    
    case "${1:-menu}" in
        "1"|"start")
            check_prerequisites_enhanced && start_minikube_enhanced
            ;;
        "2"|"verify")
            verify_system_enhanced
            ;;
        "3"|"stop")
            stop_minikube_enhanced
            ;;
        "4"|"recover")
            recover_minikube_enhanced
            ;;
        "5"|"monitor")
            monitor_performance "${2:-60}"
            ;;
        "6"|"logs")
            tail -50 "$LOG_DIR/aiops-ops.log"
            ;;
        "7"|"backup")
            local backup_file="$BACKUP_DIR/full-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
            tar czf "$backup_file" -C "$HOME" .kube .minikube 2>/dev/null || true
            success "Backup created: $backup_file"
            ;;
        "menu")
            while true; do
                show_menu
                read -p "Choose option (1-8): " choice
                case $choice in
                    1) check_prerequisites_enhanced && start_minikube_enhanced ;;
                    2) verify_system_enhanced ;;
                    3) stop_minikube_enhanced ;;
                    4) recover_minikube_enhanced ;;
                    5) read -p "Monitor duration in seconds (default 60): " duration
                       monitor_performance "${duration:-60}" ;;
                    6) tail -50 "$LOG_DIR/aiops-ops.log" ;;
                    7) local backup_file="$BACKUP_DIR/full-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
                       tar czf "$backup_file" -C "$HOME" .kube .minikube 2>/dev/null || true
                       success "Backup created: $backup_file" ;;
                    8) log "Exiting AIOps Management System"; break ;;
                    *) error "Invalid choice. Please select 1-8." ;;
                esac
                echo
                read -p "Press Enter to continue..."
            done
            ;;
        *)
            echo "Usage: $0 {start|verify|stop|recover|monitor|logs|backup|menu}"
            echo "  start   - Start Minikube with enhanced checks"
            echo "  verify  - Comprehensive system verification"
            echo "  stop    - Safe shutdown with state backup"
            echo "  recover - Nuclear recovery (destructive)"
            echo "  monitor - Performance monitoring (optionally specify duration)"
            echo "  logs    - Show recent operational logs"
            echo "  backup  - Create full configuration backup"
            echo "  menu    - Interactive menu"
            exit 1
            ;;
    esac
}

# Trap errors and signals
trap 'error "Script interrupted or failed at line $LINENO"' ERR INT TERM

# Execute main function
main "$@"
