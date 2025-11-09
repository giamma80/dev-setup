#!/bin/bash

# 🧹 Docker Cleanup Script - Universal Version
# Automatizza la pulizia generale di immagini, container e volumi Docker non necessari

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/tmp/docker_cleanup_$(date +%Y%m%d_%H%M%S).log"
DRY_RUN="false"

# Statistics tracking
declare -i CONTAINERS_REMOVED=0
declare -i IMAGES_REMOVED=0
declare -i VOLUMES_REMOVED=0
SPACE_RECLAIMED="0B"

# Function to print colored output with timestamp
log_message() {
    local level="$1"
    local message="$2"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "[$timestamp] $level $message" | tee -a "$LOG_FILE"
}

print_status() {
    log_message "${BLUE}[INFO]${NC}" "$1"
}

print_success() {
    log_message "${GREEN}[SUCCESS]${NC}" "$1"
}

print_warning() {
    log_message "${YELLOW}[WARNING]${NC}" "$1"
}

print_error() {
    log_message "${RED}[ERROR]${NC}" "$1"
}

print_header() {
    local border="${CYAN}$(printf '=%.0s' {1..60})${NC}"
    echo -e "\n$border"
    log_message "${CYAN}" "🧹 $1"
    echo -e "$border\n"
}

# Improved error handling with cleanup
cleanup_on_error() {
    print_error "Script interrupted. Cleaning up..."
    if [[ -f "$LOG_FILE" ]]; then
        print_status "Log file saved at: $LOG_FILE"
    fi
    exit 1
}

trap cleanup_on_error ERR INT TERM

# Enhanced Docker availability check
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker command not found. Please install Docker."
        exit 1
    fi

    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running or not accessible."
        print_status "Try: sudo systemctl start docker (Linux) or start Docker Desktop"
        exit 1
    fi

    # Check Docker version
    local docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    print_status "Docker version: $docker_version"
}

# Get disk usage with better parsing
get_docker_disk_usage() {
    docker system df --format "table {{.Type}}\t{{.Total}}\t{{.Active}}\t{{.Size}}\t{{.Reclaimable}}" 2>/dev/null || {
        print_warning "Could not get detailed disk usage"
        docker system df 2>/dev/null || echo "Unable to get disk usage"
    }
}

# Enhanced container cleanup with better filtering
cleanup_containers() {
    print_header "1. 🗑️ Container Cleanup"
    
    # Get stopped containers excluding protected ones
    local stopped_containers
    stopped_containers=$(docker ps -aq --filter "status=exited" --filter "status=dead" --filter "status=created")
    
    if [[ -n "$stopped_containers" ]]; then
        local count=$(echo "$stopped_containers" | wc -l)
        print_status "Found $count stopped containers"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY RUN] Would remove containers: $stopped_containers"
        else
            print_status "Removing stopped containers..."
            if docker rm $stopped_containers 2>/dev/null; then
                CONTAINERS_REMOVED=$count
                print_success "Removed $count containers"
            else
                print_warning "Some containers could not be removed (might be protected)"
            fi
        fi
    else
        print_status "No stopped containers found"
    fi
}

# Enhanced image cleanup with size tracking
cleanup_dangling_images() {
    print_header "2. 🖼️ Dangling Images Cleanup"
    
    local before_size after_size
    before_size=$(docker images -f "dangling=true" --format "{{.Size}}" | head -1 || echo "0B")
    
    if [[ "$DRY_RUN" == "true" ]]; then
        local dangling_count=$(docker images -f "dangling=true" -q | wc -l)
        print_status "[DRY RUN] Would remove $dangling_count dangling images"
        return
    fi
    
    print_status "Removing dangling images..."
    local cleanup_output
    cleanup_output=$(docker image prune -f 2>&1)
    
    if echo "$cleanup_output" | grep -q "Total reclaimed space: 0B"; then
        print_status "No dangling images found"
    else
        print_success "Dangling images removed"
        local reclaimed=$(echo "$cleanup_output" | grep "Total reclaimed space" | cut -d':' -f2 | xargs)
        print_status "Space reclaimed: $reclaimed"
    fi
}

# General unused images cleanup
cleanup_unused_images() {
    print_header "3. 🖼️ Unused Images Cleanup"
    
    local removed_count=0
    
    # Get all unused images (not referenced by any container)
    print_status "Identifying unused images..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        local unused_images
        unused_images=$(docker images --filter "dangling=false" --format "{{.ID}} {{.Repository}}:{{.Tag}} {{.Size}}" | \
            while read -r id repo size; do
                # Check if image is used by any container (running or stopped)
                if ! docker ps -a --format "{{.Image}}" | grep -q "^${repo}$\|^${id}$"; then
                    echo "$id $repo $size"
                fi
            done)
        
        if [[ -n "$unused_images" ]]; then
            local count=$(echo "$unused_images" | wc -l)
            print_status "[DRY RUN] Would remove $count unused images:"
            echo "$unused_images" | while read -r id repo size; do
                echo "  - $repo ($size)"
            done
        else
            print_status "[DRY RUN] No unused images found"
        fi
        return
    fi
    
    # Remove unused images with confirmation
    print_status "Removing unused images (keeping images used by containers)..."
    local cleanup_output
    cleanup_output=$(docker image prune -a -f 2>&1)
    
    if echo "$cleanup_output" | grep -q "Total reclaimed space: 0B"; then
        print_status "No unused images found"
    else
        print_success "Unused images removed"
        local reclaimed=$(echo "$cleanup_output" | grep "Total reclaimed space" | cut -d':' -f2 | xargs || echo "Unknown")
        print_status "Space reclaimed: $reclaimed"
        
        # Count removed (approximate from output)
        local deleted_line=$(echo "$cleanup_output" | grep "deleted:" || echo "")
        if [[ -n "$deleted_line" ]]; then
            removed_count=$(echo "$deleted_line" | wc -l)
        fi
    fi
    
    IMAGES_REMOVED=$removed_count
}

# Enhanced volume cleanup with safety checks
cleanup_volumes() {
    print_header "4. 💾 Volume Cleanup"
    
    # List unused volumes first for transparency
    local unused_volumes
    unused_volumes=$(docker volume ls -f dangling=true -q 2>/dev/null || true)
    
    if [[ -n "$unused_volumes" ]]; then
        local count=$(echo "$unused_volumes" | wc -l)
        print_status "Found $count unused volumes:"
        echo "$unused_volumes" | sed 's/^/  - /'
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY RUN] Would remove $count unused volumes"
        else
            print_status "Removing unused volumes..."
            local cleanup_output
            cleanup_output=$(docker volume prune -f 2>&1)
            
            if echo "$cleanup_output" | grep -q "Total reclaimed space: 0B"; then
                print_status "No space reclaimed from volumes"
            else
                VOLUMES_REMOVED=$count
                print_success "Removed $count unused volumes"
                local reclaimed=$(echo "$cleanup_output" | grep "Total reclaimed space" | cut -d':' -f2 | xargs || echo "Unknown")
                print_status "Space reclaimed: $reclaimed"
            fi
        fi
    else
        print_status "No unused volumes found"
    fi
}

# Enhanced build cache cleanup
cleanup_build_cache() {
    print_header "5. 🔄 Build Cache Cleanup"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY RUN] Would remove Docker build cache"
        return
    fi
    
    print_status "Removing Docker build cache..."
    local cleanup_output
    
    # Try buildx prune first (newer Docker versions)
    if docker buildx version &> /dev/null; then
        cleanup_output=$(docker buildx prune -f 2>&1 || echo "No buildx cache to remove")
    else
        cleanup_output=$(docker builder prune -f 2>&1 || echo "No build cache to remove")
    fi
    
    if echo "$cleanup_output" | grep -q "Total reclaimed space"; then
        print_success "Build cache removed"
        local reclaimed=$(echo "$cleanup_output" | grep "Total reclaimed space" | cut -d':' -f2 | xargs)
        print_status "Space reclaimed: $reclaimed"
        SPACE_RECLAIMED="$reclaimed"
    else
        print_status "No build cache found or already clean"
    fi
}

# Network cleanup (new feature)
cleanup_networks() {
    print_header "6. 🌐 Network Cleanup"
    
    local unused_networks
    unused_networks=$(docker network ls --filter "type=custom" --format "{{.ID}} {{.Name}}" | grep -v -E "(bridge|host|none)" || true)
    
    if [[ -n "$unused_networks" ]]; then
        print_status "Checking for unused custom networks..."
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY RUN] Would check and remove unused networks"
        else
            # Only remove networks that have no containers
            docker network prune -f > /dev/null 2>&1 || true
            print_success "Unused networks cleaned up"
        fi
    else
        print_status "No custom networks to clean"
    fi
}

# Comprehensive final report
show_final_report() {
    print_header "📊 Cleanup Summary"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "DRY RUN MODE - No actual changes made"
        print_status "Log file: $LOG_FILE"
        return
    fi
    
    # Statistics
    print_status "Cleanup Statistics:"
    echo "  📦 Containers removed: $CONTAINERS_REMOVED"
    echo "  🖼️  Images removed: $IMAGES_REMOVED"
    echo "  💾 Volumes removed: $VOLUMES_REMOVED"
    if [[ "$SPACE_RECLAIMED" != "0B" ]]; then
        echo "  💽 Space reclaimed: $SPACE_RECLAIMED"
    fi
    echo ""
    
    # Current usage
    print_status "Current Docker disk usage:"
    echo ""
    get_docker_disk_usage
    echo ""
    
    # Remaining images
    local remaining_images
    remaining_images=$(docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | head -20)
    
    if [[ -n "$remaining_images" ]]; then
        print_status "Remaining images (showing first 20):"
        echo ""
        echo "$remaining_images"
        echo ""
    fi
    
    print_success "Log file saved: $LOG_FILE"
}

# Enhanced main function with better flow
main() {
    print_header "🧹 Docker Universal Cleanup"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
    fi
    
    print_status "Starting cleanup process..."
    print_status "Log file: $LOG_FILE"
    
    # Pre-flight checks
    check_docker
    
    # Show initial state
    print_status "Initial Docker disk usage:"
    echo ""
    get_docker_disk_usage
    echo ""
    
    # Cleanup phases
    cleanup_containers
    cleanup_dangling_images
    cleanup_unused_images
    cleanup_volumes
    cleanup_build_cache
    cleanup_networks
    
    # Final report
    show_final_report
    
    print_header "✅ Cleanup Complete!"
    print_success "Docker cleanup completed successfully!"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "🌟 Your Docker environment is now optimized:"
        print_status "• Removed unused containers, images, and volumes"
        print_status "• Cleaned build cache and unused networks" 
        print_status "• Only actively used resources remain"
        echo -e "\n${GREEN}🎉 Docker environment successfully optimized!${NC}\n"
    fi
}

# Help function
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Docker Universal Cleanup Script - Optimized Version

OPTIONS:
    dry-run     Show what would be cleaned without making changes
    help        Show this help message

EXAMPLES:
    $SCRIPT_NAME              # Run full cleanup
    $SCRIPT_NAME dry-run      # Preview cleanup actions
    $SCRIPT_NAME help         # Show help

FEATURES:
    • Safe container cleanup (stopped/dead containers only)
    • Dangling images removal
    • Unused images cleanup (not referenced by any container)
    • Volume cleanup with safety checks
    • Build cache cleanup (buildx support)
    • Network cleanup
    • Comprehensive logging
    • Dry-run mode for testing
    • Enhanced error handling
    • Statistics tracking

EOF
}

# Parse arguments
case "${1:-}" in
    "help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    "dry-run"|"--dry-run")
        DRY_RUN="true"
        ;;
    "")
        # No arguments, proceed with normal execution
        DRY_RUN="false"
        ;;
    *)
        print_error "Unknown argument: $1"
        show_help
        exit 1
        ;;
esac

# Run main function
main "$@"
