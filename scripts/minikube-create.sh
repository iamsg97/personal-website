#!/bin/bash

# Personal Website Minikube Cluster Management Script
# This script creates a multi-node Minikube cluster optimized for the personal website deployment
#
# Author: Suvadeep Ghoshal
# Version: 1.0.0
# Date: 2025-06-23

set -euo pipefail # Exit on error, undefined vars, pipe failures

# ============================================================================
# CONFIGURATION
# ============================================================================

# Cluster configuration
readonly CLUSTER_NAME="personal-website-server"
readonly DEFAULT_DRIVER="docker"
readonly DEFAULT_NODES=3
readonly CPUS=2
readonly MEMORY="2g"
readonly K8S_VERSION="v1.31.0"
readonly CONTAINER_RUNTIME="containerd"
readonly CNI="calico"

# Runtime configuration (can be overridden by command line)
DRIVER="$DEFAULT_DRIVER"
NODES="$DEFAULT_NODES"

# Worker node labels (will be generated dynamically based on NODES)
generate_worker_node_labels() {
	local worker_count=$((NODES - 1)) # Subtract 1 for control plane
	WORKER_NODE_LABELS=()

	for ((i = 1; i <= worker_count; i++)); do
		WORKER_NODE_LABELS+=("personal-website-server-worker-node-$(printf "%02d" $i)")
	done
}

# Colors for pretty output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Log levels
readonly LOG_ERROR="ERROR"
readonly LOG_WARN="WARN"
readonly LOG_INFO="INFO"
readonly LOG_SUCCESS="SUCCESS"
readonly LOG_DEBUG="DEBUG"

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

# Function to print colored output with timestamp
log() {
	local level="$1"
	local message="$2"
	local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

	case "$level" in
	"$LOG_ERROR")
		echo -e "${RED}[${timestamp}] ❌ ERROR: ${message}${NC}" >&2
		;;
	"$LOG_WARN")
		echo -e "${YELLOW}[${timestamp}] ⚠️  WARN:  ${message}${NC}"
		;;
	"$LOG_INFO")
		echo -e "${BLUE}[${timestamp}] ℹ️  INFO:  ${message}${NC}"
		;;
	"$LOG_SUCCESS")
		echo -e "${GREEN}[${timestamp}] ✅ SUCCESS: ${message}${NC}"
		;;
	"$LOG_DEBUG")
		echo -e "${PURPLE}[${timestamp}] 🔍 DEBUG: ${message}${NC}"
		;;
	*)
		echo -e "${WHITE}[${timestamp}] ${message}${NC}"
		;;
	esac
}

# Convenience functions for different log levels
log_error() { log "$LOG_ERROR" "$1"; }
log_warn() { log "$LOG_WARN" "$1"; }
log_info() { log "$LOG_INFO" "$1"; }
log_success() { log "$LOG_SUCCESS" "$1"; }
log_debug() { log "$LOG_DEBUG" "$1"; }

# Function to print section headers
print_section() {
	echo ""
	echo -e "${CYAN}============================================================================${NC}"
	echo -e "${WHITE}  $1${NC}"
	echo -e "${CYAN}============================================================================${NC}"
	echo ""
}

# Function to print step headers
print_step() {
	echo ""
	echo -e "${PURPLE}📋 Step $1: $2${NC}"
	echo -e "${PURPLE}────────────────────────────────────────────────────────────────────────${NC}"
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to show script usage
show_usage() {
	cat <<EOF
${WHITE}Personal Website Minikube Cluster Setup${NC}

${CYAN}SYNOPSIS${NC}
    $0 [OPTIONS]

${CYAN}DESCRIPTION${NC}
    Creates a multi-node Minikube cluster optimized for personal website deployment.
    The cluster includes 1 control plane and 2 worker nodes with appropriate labeling.

${CYAN}OPTIONS${NC}
    -h, --help              Show this help message and exit
    -v, --verbose           Enable verbose output (debug mode)
    -f, --force             Force recreate cluster if it already exists
    -c, --check-only        Only check prerequisites, don't create cluster
    -d, --driver DRIVER     Virtualization driver (default: ${DEFAULT_DRIVER})
    -n, --nodes COUNT       Number of nodes (default: ${DEFAULT_NODES})
    --debug                 Enable debug mode with detailed minikube output
    --dry-run               Show what would be executed without running commands

${CYAN}DRIVER OPTIONS${NC}
    docker                  Fast, lightweight (recommended for development)
    virtualbox              Full isolation, cross-platform
    kvm2                    Best performance on Linux
    hyperkit                Native macOS virtualization
    vmware                  VMware Workstation/Fusion
    none                    Run on host directly (no isolation)

${CYAN}CLUSTER CONFIGURATION${NC}
    Profile Name:           ${CLUSTER_NAME}
    Driver (default):       ${DEFAULT_DRIVER}
    Nodes (default):        ${DEFAULT_NODES}
    CPUs per node:          ${CPUS}
    Memory per node:        ${MEMORY}
    Kubernetes Version:     ${K8S_VERSION}
    Container Runtime:      ${CONTAINER_RUNTIME}
    CNI:                    ${CNI}

${CYAN}WORKER NODE LABELS${NC}
    Labels are generated dynamically based on node count:
    Format: personal-website-server-worker-node-XX

${CYAN}EXAMPLES${NC}
    # Create cluster with default settings (docker driver, 3 nodes)
    $0

    # Create cluster with verbose output
    $0 --verbose

    # Create cluster with 5 nodes using VirtualBox
    $0 --nodes 5 --driver virtualbox

    # Create single-node cluster with Docker
    $0 --nodes 1 --driver docker

    # Force recreate existing cluster with custom settings
    $0 --force --nodes 4 --driver kvm2

    # Check prerequisites only
    $0 --check-only

    # Dry run to see what would be executed
    $0 --dry-run --nodes 2 --driver virtualbox

    # Debug mode with detailed minikube output
    $0 --debug --verbose

${CYAN}PREREQUISITES${NC}
    - Minikube installed and in PATH
    - kubectl installed and in PATH
    - Driver-specific requirements:
      * docker: Docker installed and running
      * virtualbox: VirtualBox installed
      * kvm2: KVM installed (Linux only)
      * hyperkit: Hyperkit installed (macOS only)
    - Sufficient RAM: ${MEMORY} × number of nodes
    - At least 20GB free disk space

${CYAN}EXIT CODES${NC}
    0    Success
    1    General error
    2    Prerequisites not met
    3    Cluster creation failed
    4    Node labeling failed

${CYAN}AUTHOR${NC}
    Suvadeep Ghoshal <ghoshalsuvadeep594@gmail.com>

${CYAN}VERSION${NC}
    1.0.0

EOF
}

# Function to check prerequisites
check_prerequisites() {
	print_step "1" "Checking Prerequisites"

	local prerequisites_met=true

	# Check if minikube is installed
	if ! command_exists minikube; then
		log_error "minikube is not installed or not in PATH"
		log_info "Install minikube: https://minikube.sigs.k8s.io/docs/start/"
		prerequisites_met=false
	else
		local minikube_version=$(minikube version --short 2>/dev/null | cut -d'v' -f2)
		log_success "minikube found (version: v${minikube_version})"
	fi

	# Check if kubectl is installed
	if ! command_exists kubectl; then
		log_error "kubectl is not installed or not in PATH"
		log_info "Install kubectl: https://kubernetes.io/docs/tasks/tools/"
		prerequisites_met=false
	else
		local kubectl_version=$(kubectl version --client --short 2>/dev/null | cut -d'v' -f2)
		log_success "kubectl found (version: v${kubectl_version})"
	fi

	# Check driver-specific prerequisites
	case "$DRIVER" in
	"virtualbox")
		if ! command_exists VBoxManage; then
			log_error "VirtualBox is not installed or VBoxManage not in PATH"
			log_info "Install VirtualBox: https://www.virtualbox.org/wiki/Downloads"
			prerequisites_met=false
		else
			local vbox_version=$(VBoxManage --version 2>/dev/null | cut -d'r' -f1)
			log_success "VirtualBox found (version: ${vbox_version})"
		fi
		;;
	"docker")
		if ! command_exists docker; then
			log_error "Docker is not installed or not in PATH"
			log_info "Install Docker: https://docs.docker.com/get-docker/"
			prerequisites_met=false
		else
			if ! docker info >/dev/null 2>&1; then
				log_error "Docker is installed but not running"
				log_info "Start Docker service or Docker Desktop"
				prerequisites_met=false
			else
				local docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
				log_success "Docker found and running (version: ${docker_version})"
			fi
		fi
		;;
	"kvm2")
		if ! command_exists virsh; then
			log_error "KVM/libvirt is not installed"
			log_info "Install KVM: sudo apt-get install qemu-kvm libvirt-daemon-system (Ubuntu/Debian)"
			prerequisites_met=false
		else
			log_success "KVM/libvirt found"
		fi
		;;
	"hyperkit")
		if [[ "$(uname)" != "Darwin" ]]; then
			log_error "Hyperkit driver is only available on macOS"
			prerequisites_met=false
		elif ! command_exists hyperkit; then
			log_error "Hyperkit is not installed"
			log_info "Install hyperkit: brew install hyperkit"
			prerequisites_met=false
		else
			log_success "Hyperkit found"
		fi
		;;
	"vmware")
		if [[ "$(uname)" == "Darwin" ]]; then
			if ! command_exists vmrun; then
				log_error "VMware Fusion is not installed"
				log_info "Install VMware Fusion"
				prerequisites_met=false
			else
				log_success "VMware Fusion found"
			fi
		else
			if ! command_exists vmrun; then
				log_error "VMware Workstation is not installed"
				log_info "Install VMware Workstation"
				prerequisites_met=false
			else
				log_success "VMware Workstation found"
			fi
		fi
		;;
	"none")
		log_warn "Using 'none' driver - Kubernetes will run directly on host"
		log_warn "This may conflict with existing services"
		;;
	*)
		log_warn "Unknown driver '$DRIVER' - skipping driver-specific checks"
		;;
	esac

	# Check available memory (Linux/Mac)
	if command_exists free; then
		local available_memory_mb=$(free -m | awk 'NR==2{printf "%.0f", $7}')
		local required_memory_mb=$((${MEMORY%g} * 1024 * NODES))

		if [[ $available_memory_mb -lt $required_memory_mb ]]; then
			log_warn "Available memory (${available_memory_mb}MB) might be insufficient"
			log_warn "Required memory: ${required_memory_mb}MB"
		else
			log_success "Sufficient memory available (${available_memory_mb}MB)"
		fi
	elif command_exists vm_stat; then
		# macOS memory check
		local free_pages=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
		local available_memory_mb=$((free_pages * 4096 / 1024 / 1024))
		local required_memory_mb=$((${MEMORY%g} * 1024 * NODES))

		if [[ $available_memory_mb -lt $required_memory_mb ]]; then
			log_warn "Available memory (${available_memory_mb}MB) might be insufficient"
			log_warn "Required memory: ${required_memory_mb}MB"
		else
			log_success "Sufficient memory available (${available_memory_mb}MB)"
		fi
	fi

	# Check disk space
	local available_disk_gb=$(df . | awk 'NR==2 {printf "%.0f", $4/1024/1024}')
	if [[ $available_disk_gb -lt 20 ]]; then
		log_warn "Available disk space (${available_disk_gb}GB) might be insufficient"
		log_warn "Recommended: at least 20GB free space"
	else
		log_success "Sufficient disk space available (${available_disk_gb}GB)"
	fi

	if [[ "$prerequisites_met" == "false" ]]; then
		log_error "Prerequisites not met. Please install missing components."
		exit 2
	fi

	log_success "All prerequisites met!"
}

# Function to check if cluster already exists
check_existing_cluster() {
	print_step "2" "Checking Existing Cluster"

	if minikube profile list 2>/dev/null | grep -q "$CLUSTER_NAME"; then
		log_warn "Cluster '$CLUSTER_NAME' already exists"

		if [[ "${FORCE_RECREATE:-false}" == "true" ]]; then
			log_info "Force flag detected. Deleting existing cluster..."
			if [[ "${DRY_RUN:-false}" == "true" ]]; then
				log_debug "DRY RUN: minikube delete --profile $CLUSTER_NAME"
			else
				minikube delete --profile "$CLUSTER_NAME" || {
					log_error "Failed to delete existing cluster"
					exit 3
				}
			fi
			log_success "Existing cluster deleted"
		else
			log_error "Cluster already exists. Use --force to recreate or choose a different profile name."
			log_info "To delete manually: minikube delete --profile $CLUSTER_NAME"
			exit 3
		fi
	else
		log_success "No existing cluster found. Proceeding with creation."
	fi
}

# Function to create the Minikube cluster
create_cluster() {
	print_step "3" "Creating Minikube Cluster"

	log_info "Creating cluster with configuration:"
	log_info "  Profile: $CLUSTER_NAME"
	log_info "  Driver: $DRIVER"
	log_info "  Nodes: $NODES"
	log_info "  CPUs: $CPUS per node"
	log_info "  Memory: $MEMORY per node"
	log_info "  Kubernetes: $K8S_VERSION"
	log_info "  Runtime: $CONTAINER_RUNTIME"
	log_info "  CNI: $CNI"

	local minikube_cmd=(
		minikube start
		--driver="$DRIVER"
		--nodes="$NODES"
		--cpus="$CPUS"
		--memory="$MEMORY"
		--kubernetes-version="$K8S_VERSION"
		--container-runtime="$CONTAINER_RUNTIME"
		--cni="$CNI"
		--profile="$CLUSTER_NAME"
	)

	# Add debug flags if debug mode is enabled
	if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
		minikube_cmd+=(--alsologtostderr --v=7)
		log_debug "Debug mode enabled - adding verbose minikube flags"
	fi

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		log_debug "DRY RUN: ${minikube_cmd[*]}"
		return 0
	fi

	log_info "Starting cluster creation (this may take several minutes)..."

	# Show the actual command being executed
	if [[ "${DEBUG_MODE:-false}" == "true" ]] || [[ "${VERBOSE:-false}" == "true" ]]; then
		log_debug "Executing command: ${minikube_cmd[*]}"
	fi

	# Check if we should delete any existing partial clusters first
	log_info "Checking for any existing cluster state..."
	if minikube profile list 2>/dev/null | grep -q "$CLUSTER_NAME"; then
		log_warn "Found existing cluster profile. Cleaning up..."
		minikube delete --profile "$CLUSTER_NAME" >/dev/null 2>&1 || true
		sleep 2
	fi

	# Execute the minikube start command with appropriate output handling
	local start_time=$(date +%s)

	if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
		log_info "=== MINIKUBE DEBUG OUTPUT START ==="
		"${minikube_cmd[@]}" 2>&1 | while IFS= read -r line; do
			echo -e "${PURPLE}[MINIKUBE] ${line}${NC}"
		done
		local exit_code=${PIPESTATUS[0]}
		log_info "=== MINIKUBE DEBUG OUTPUT END ==="
	elif [[ "${VERBOSE:-false}" == "true" ]]; then
		"${minikube_cmd[@]}" 2>&1 | while IFS= read -r line; do
			log_info "minikube: $line"
		done
		local exit_code=${PIPESTATUS[0]}
	else
		# Capture output for error reporting but don't show it unless there's an error
		local output
		if ! output=$("${minikube_cmd[@]}" 2>&1); then
			local exit_code=$?
			log_error "Minikube command failed with exit code $exit_code"
			log_error "Minikube output:"
			echo "$output" | while IFS= read -r line; do
				log_error "  $line"
			done
		else
			local exit_code=0
		fi
	fi

	local end_time=$(date +%s)
	local duration=$((end_time - start_time))

	if [[ ${exit_code:-0} -ne 0 ]]; then
		log_error "Failed to create Minikube cluster (took ${duration}s)"
		log_info "Attempting to gather diagnostic information..."

		# Try to get more detailed error information
		log_info "Checking minikube logs..."
		if minikube logs --profile "$CLUSTER_NAME" >/dev/null 2>&1; then
			log_info "Minikube logs for profile $CLUSTER_NAME:"
			minikube logs --profile "$CLUSTER_NAME" 2>&1 | tail -20 | while IFS= read -r line; do
				log_error "  LOG: $line"
			done
		fi

		# Check Docker status if using docker driver
		if [[ "$DRIVER" == "docker" ]]; then
			log_info "Checking Docker status..."
			if ! docker info >/dev/null 2>&1; then
				log_error "Docker is not running properly"
			else
				local docker_containers=$(docker ps -a --filter "name=$CLUSTER_NAME" --format "table {{.Names}}\t{{.Status}}")
				if [[ -n "$docker_containers" ]]; then
					log_info "Docker containers for cluster:"
					echo "$docker_containers" | while IFS= read -r line; do
						log_info "  $line"
					done
				fi
			fi
		fi

		log_info "Troubleshooting suggestions:"
		case "$DRIVER" in
		"docker")
			log_info "  1. Ensure Docker has enough resources allocated"
			log_info "  2. Try: docker system prune -f"
			log_info "  3. Restart Docker Desktop if on Windows/Mac"
			log_info "  4. Check Docker version compatibility"
			;;
		"virtualbox")
			log_info "  1. Ensure VirtualBox is updated to latest version"
			log_info "  2. Check if virtualization is enabled in BIOS"
			log_info "  3. Try with fewer nodes or less memory"
			;;
		*)
			log_info "  1. Check driver-specific documentation"
			log_info "  2. Try with a different driver"
			log_info "  3. Ensure sufficient system resources"
			;;
		esac

		log_info "For more details, run with --debug --verbose flags"
		exit 3
	fi

	log_success "Minikube cluster created successfully! (took ${duration}s)"

	# Wait a moment for cluster to stabilize
	log_info "Waiting for cluster to stabilize..."
	sleep 5
}

# Function to label worker nodes
label_worker_nodes() {
	print_step "4" "Labeling Worker Nodes"

	# Wait a moment for nodes to be ready
	log_info "Waiting for nodes to be ready..."
	if [[ "${DRY_RUN:-false}" != "true" ]]; then
		sleep 10

		# Switch to the cluster context
		kubectl config use-context "$CLUSTER_NAME" >/dev/null 2>&1 || {
			log_error "Failed to switch to cluster context"
			exit 4
		}

		# Wait for all nodes to be ready
		log_info "Waiting for all nodes to be in Ready state..."
		kubectl wait --for=condition=Ready nodes --all --timeout=300s || {
			log_error "Nodes did not become ready within timeout"
			exit 4
		}
	fi

	# Get worker nodes (exclude control plane)
	local worker_nodes=()
	local expected_worker_count=$((NODES - 1))

	if [[ "${DRY_RUN:-false}" != "true" ]]; then
		mapfile -t worker_nodes < <(kubectl get nodes --no-headers | grep -v "control-plane" | awk '{print $1}')
	else
		# For dry run, simulate worker node names
		for ((i = 2; i <= NODES; i++)); do
			worker_nodes+=("${CLUSTER_NAME}-m$(printf "%02d" $i)")
		done
	fi

	if [[ ${#worker_nodes[@]} -ne $expected_worker_count ]]; then
		log_error "Expected $expected_worker_count worker nodes, found ${#worker_nodes[@]}"
		if [[ "${DRY_RUN:-false}" != "true" ]]; then
			log_info "Current nodes:"
			kubectl get nodes
		fi
		exit 4
	fi

	# Label each worker node
	for i in "${!worker_nodes[@]}"; do
		local node_name="${worker_nodes[$i]}"
		local label_value="${WORKER_NODE_LABELS[$i]}"

		log_info "Labeling node '$node_name' with 'worker-label=$label_value'"

		if [[ "${DRY_RUN:-false}" == "true" ]]; then
			log_debug "DRY RUN: kubectl label node $node_name worker-label=$label_value"
		else
			kubectl label node "$node_name" "worker-label=$label_value" || {
				log_error "Failed to label node '$node_name'"
				exit 4
			}
		fi

		log_success "Successfully labeled node '$node_name'"
	done
}

# Function to verify cluster setup
verify_cluster() {
	print_step "5" "Verifying Cluster Setup"

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		log_debug "DRY RUN: Cluster verification would be performed here"
		return 0
	fi

	# Check cluster status
	log_info "Checking cluster status..."
	local cluster_status=$(minikube status --profile "$CLUSTER_NAME" --format="{{.Host}}" 2>/dev/null)
	if [[ "$cluster_status" == "Running" ]]; then
		log_success "Cluster is running"
	else
		log_error "Cluster is not running (status: $cluster_status)"
		exit 3
	fi

	# Check nodes
	log_info "Checking node status..."
	kubectl get nodes --show-labels || {
		log_error "Failed to get node information"
		exit 4
	}

	# Verify node labels
	log_info "Verifying worker node labels..."
	for label_value in "${WORKER_NODE_LABELS[@]}"; do
		local node_count=$(kubectl get nodes -l "worker-label=$label_value" --no-headers | wc -l)
		if [[ $node_count -eq 1 ]]; then
			log_success "Found node with label 'worker-label=$label_value'"
		else
			log_error "Expected 1 node with label 'worker-label=$label_value', found $node_count"
			exit 4
		fi
	done

	# Check cluster info
	log_info "Cluster information:"
	kubectl cluster-info

	log_success "Cluster verification completed successfully!"
}

# Function to display cluster access information
show_cluster_info() {
	print_step "6" "Cluster Access Information"

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		log_debug "DRY RUN: Cluster access information would be displayed here"
		return 0
	fi

	log_info "Cluster setup completed successfully!"
	echo ""
	echo -e "${WHITE}To use this cluster:${NC}"
	echo -e "  ${CYAN}kubectl config use-context $CLUSTER_NAME${NC}"
	echo ""
	echo -e "${WHITE}To check cluster status:${NC}"
	echo -e "  ${CYAN}minikube status --profile $CLUSTER_NAME${NC}"
	echo ""
	echo -e "${WHITE}To access Kubernetes dashboard:${NC}"
	echo -e "  ${CYAN}minikube dashboard --profile $CLUSTER_NAME${NC}"
	echo ""
	echo -e "${WHITE}To delete this cluster:${NC}"
	echo -e "  ${CYAN}minikube delete --profile $CLUSTER_NAME${NC}"
	echo ""
	echo -e "${WHITE}To SSH into cluster nodes:${NC}"
	echo -e "  ${CYAN}minikube ssh --profile $CLUSTER_NAME${NC} (control plane)"

	# Show SSH commands for worker nodes if any exist
	if [[ $NODES -gt 1 ]]; then
		for ((i = 2; i <= NODES; i++)); do
			echo -e "  ${CYAN}minikube ssh --profile $CLUSTER_NAME --node $CLUSTER_NAME-m$(printf "%02d" $i)${NC} (worker node $((i - 1)))"
		done
	fi
	echo ""
}

# Function to handle cleanup on script exit
cleanup() {
	local exit_code=$?
	if [[ $exit_code -ne 0 ]] && [[ "${DRY_RUN:-false}" != "true" ]]; then
		log_error "Script exited with error code $exit_code"

		if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
			log_info "Running diagnostics due to error..."
			diagnose_cluster_issues
		fi

		log_info "If cluster creation failed partially, you may need to run:"
		log_info "  minikube delete --profile $CLUSTER_NAME"
		log_info "For detailed debugging, run with --debug --verbose"
	fi
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
	# Set up signal handling
	trap cleanup EXIT

	# Parse command line arguments
	local check_only=false

	while [[ $# -gt 0 ]]; do
		case $1 in
		-h | --help)
			show_usage
			exit 0
			;;
		-v | --verbose)
			VERBOSE=true
			log_debug "Verbose mode enabled"
			shift
			;;
		-f | --force)
			FORCE_RECREATE=true
			log_debug "Force recreate mode enabled"
			shift
			;;
		-c | --check-only)
			check_only=true
			log_debug "Check-only mode enabled"
			shift
			;;
		-d | --driver)
			if [[ -z "$2" ]] || [[ "$2" == -* ]]; then
				log_error "Driver option requires a value"
				exit 1
			fi
			DRIVER="$2"
			log_debug "Driver set to: $DRIVER"
			shift 2
			;;
		-n | --nodes)
			if [[ -z "$2" ]] || [[ "$2" == -* ]]; then
				log_error "Nodes option requires a value"
				exit 1
			fi
			if ! [[ "$2" =~ ^[0-9]+$ ]] || [[ "$2" -lt 1 ]]; then
				log_error "Nodes must be a positive integer (got: $2)"
				exit 1
			fi
			NODES="$2"
			log_debug "Nodes set to: $NODES"
			shift 2
			;;
		--dry-run)
			DRY_RUN=true
			log_debug "Dry run mode enabled"
			shift
			;;
		--debug)
			DEBUG_MODE=true
			VERBOSE=true # Debug mode implies verbose
			log_debug "Debug mode enabled (includes verbose output)"
			shift
			;;
		*)
			log_error "Unknown option: $1"
			log_info "Use --help for usage information"
			exit 1
			;;
		esac
	done

	# Print script header
	print_section "Personal Website Minikube Cluster Setup"
	log_info "Starting cluster creation process..."
	log_info "Configuration: Driver=$DRIVER, Nodes=$NODES"

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		log_warn "DRY RUN MODE: No actual changes will be made"
	fi

	# Generate worker node labels based on node count
	generate_worker_node_labels
	log_debug "Generated ${#WORKER_NODE_LABELS[@]} worker node labels"

	# Execute steps
	check_prerequisites

	if [[ "$check_only" == "true" ]]; then
		log_success "Prerequisites check completed. Exiting as requested."
		exit 0
	fi

	check_existing_cluster
	create_cluster
	label_worker_nodes
	verify_cluster
	show_cluster_info

	log_success "Cluster setup completed successfully!"
}

# Function to diagnose cluster issues
diagnose_cluster_issues() {
	log_info "=== CLUSTER DIAGNOSTICS ==="

	# Check minikube status
	log_info "Minikube status:"
	if minikube status --profile "$CLUSTER_NAME" 2>&1; then
		: # Command succeeded
	else
		log_error "Failed to get minikube status"
	fi

	# Check minikube version
	log_info "Minikube version:"
	minikube version

	# Check system resources
	log_info "System resources:"
	if command_exists free; then
		free -h
	elif command_exists vm_stat; then
		vm_stat
	fi

	# Check Docker if using docker driver
	if [[ "$DRIVER" == "docker" ]]; then
		log_info "Docker information:"
		docker version 2>/dev/null || log_error "Failed to get Docker version"
		docker info 2>/dev/null | grep -E "(CPUs|Total Memory|Server Version)" || log_error "Failed to get Docker info"

		log_info "Docker containers related to minikube:"
		docker ps -a --filter "name=minikube" --filter "name=$CLUSTER_NAME" 2>/dev/null || log_error "Failed to list Docker containers"
	fi

	# Check available disk space
	log_info "Disk space:"
	df -h . 2>/dev/null || log_error "Failed to check disk space"

	log_info "=== END DIAGNOSTICS ==="
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
