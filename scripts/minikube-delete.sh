#!/bin/bash

# Personal Website Minikube Cluster Deletion Script
# This script safely deletes all Minikube clusters and purges all data
#
# Author: Suvadeep Ghoshal
# Version: 1.0.0
# Date: $(date +%Y-%m-%d)

set -euo pipefail # Exit on error, undefined vars, pipe failures

# ============================================================================
# CONFIGURATION
# ============================================================================

# Default cluster name (can be overridden)
readonly DEFAULT_CLUSTER_NAME="personal-website-server"

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
${WHITE}Personal Website Minikube Cluster Deletion Tool${NC}

${CYAN}SYNOPSIS${NC}
    $0 [OPTIONS] [PROFILE_NAME]

${CYAN}DESCRIPTION${NC}
    Safely deletes Minikube clusters with confirmation prompts and comprehensive
    cleanup options. Can delete specific profiles or all clusters at once.

${CYAN}OPTIONS${NC}
    -h, --help              Show this help message and exit
    -v, --verbose           Enable verbose output (debug mode)
    -y, --yes               Skip confirmation prompts (automatic yes)
    -f, --force             Force deletion even if cluster is running
    -a, --all               Delete all Minikube profiles
    -p, --purge             Purge all Minikube data after deletion
    -l, --list              List all existing profiles and exit
    --dry-run               Show what would be deleted without executing

${CYAN}ARGUMENTS${NC}
    PROFILE_NAME            Name of the specific profile to delete
                           (default: ${DEFAULT_CLUSTER_NAME})

${CYAN}DELETION MODES${NC}
    Single Profile:         Delete a specific Minikube profile
    All Profiles:           Delete all existing Minikube profiles (--all)
    With Purge:             Remove all Minikube configuration data (--purge)

${CYAN}EXAMPLES${NC}
    # Delete default personal website cluster
    $0

    # Delete specific profile
    $0 my-cluster

    # Delete all clusters with confirmation
    $0 --all

    # Delete all clusters and purge data (no confirmation)
    $0 --all --purge --yes

    # List all existing profiles
    $0 --list

    # Dry run to see what would be deleted
    $0 --all --dry-run

    # Force delete running cluster
    $0 my-cluster --force

${CYAN}SAFETY FEATURES${NC}
    - Confirmation prompts before deletion
    - Status checks before proceeding
    - Dry run mode for testing
    - Detailed logging of all operations
    - Graceful error handling

${CYAN}EXIT CODES${NC}
    0    Success
    1    General error
    2    Prerequisites not met
    3    No clusters found to delete
    4    User cancelled operation
    5    Deletion failed

${CYAN}AUTHOR${NC}
    Suvadeep Ghoshal <suvadeepghoshal@example.com>

${CYAN}VERSION${NC}
    1.0.0

EOF
}

# Function to check prerequisites
check_prerequisites() {
	print_step "1" "Checking Prerequisites"

	# Check if minikube is installed
	if ! command_exists minikube; then
		log_error "minikube is not installed or not in PATH"
		log_info "Install minikube: https://minikube.sigs.k8s.io/docs/start/"
		exit 2
	else
		local minikube_version=$(minikube version --short 2>/dev/null | cut -d'v' -f2)
		log_success "minikube found (version: v${minikube_version})"
	fi

	log_success "Prerequisites check completed!"
}

# Function to list all profiles
list_profiles() {
	print_step "2" "Listing Minikube Profiles"

	local profiles_output
	if ! profiles_output=$(minikube profile list 2>/dev/null); then
		log_warn "No Minikube profiles found or unable to list profiles"
		return 1
	fi

	# Extract profile names (skip header)
	local profiles=($(echo "$profiles_output" | tail -n +2 | awk '{print $1}' | grep -v "^$"))

	if [[ ${#profiles[@]} -eq 0 ]]; then
		log_warn "No Minikube profiles found"
		return 1
	fi

	log_info "Found ${#profiles[@]} Minikube profile(s):"
	echo ""
	echo "$profiles_output"
	echo ""

	return 0
}

# Function to get profile status
get_profile_status() {
	local profile_name="$1"
	local status_output

	if status_output=$(minikube status --profile "$profile_name" 2>/dev/null); then
		echo "$status_output"
		return 0
	else
		echo "Unknown"
		return 1
	fi
}

# Function to confirm deletion
confirm_deletion() {
	local profile_name="$1"
	local delete_all="${2:-false}"

	if [[ "${AUTO_YES:-false}" == "true" ]]; then
		log_info "Auto-confirmation enabled, proceeding with deletion"
		return 0
	fi

	echo ""
	if [[ "$delete_all" == "true" ]]; then
		log_warn "🚨 This will DELETE ALL Minikube clusters and their data!"
		log_warn "This action cannot be undone!"
	else
		log_warn "🚨 This will DELETE the cluster: $profile_name"
		log_warn "All data in this cluster will be lost!"
	fi

	echo ""
	read -p "Are you sure you want to proceed? (yes/no): " -r
	echo ""

	case "$REPLY" in
	yes | YES | Yes)
		log_info "Deletion confirmed by user"
		return 0
		;;
	*)
		log_info "Deletion cancelled by user"
		exit 4
		;;
	esac
}

# Function to delete a specific profile
delete_profile() {
	local profile_name="$1"
	local force="${2:-false}"

	log_info "Checking status of profile: $profile_name"

	# Check if profile exists
	if ! minikube profile list 2>/dev/null | grep -q "^$profile_name"; then
		log_warn "Profile '$profile_name' does not exist"
		return 1
	fi

	# Get profile status
	local status=$(minikube status --profile "$profile_name" --format="{{.Host}}" 2>/dev/null || echo "Unknown")
	log_info "Profile '$profile_name' status: $status"

	# Check if cluster is running and force is not enabled
	if [[ "$status" == "Running" ]] && [[ "$force" != "true" ]]; then
		log_warn "Cluster '$profile_name' is currently running"
		log_info "Use --force to delete running clusters or stop it first with:"
		log_info "  minikube stop --profile $profile_name"
		return 1
	fi

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		log_debug "DRY RUN: minikube delete --profile $profile_name"
		return 0
	fi

	log_info "Deleting profile: $profile_name"

	if [[ "${VERBOSE:-false}" == "true" ]]; then
		minikube delete --profile "$profile_name" || {
			log_error "Failed to delete profile: $profile_name"
			return 1
		}
	else
		minikube delete --profile "$profile_name" >/dev/null 2>&1 || {
			log_error "Failed to delete profile: $profile_name"
			log_info "Run with --verbose for detailed output"
			return 1
		}
	fi

	log_success "Successfully deleted profile: $profile_name"
	return 0
}

# Function to delete all profiles
delete_all_profiles() {
	local force="${1:-false}"

	# Get list of all profiles
	local profiles_output
	if ! profiles_output=$(minikube profile list 2>/dev/null); then
		log_warn "No Minikube profiles found to delete"
		exit 3
	fi

	# Extract profile names (skip header)
	local profiles=($(echo "$profiles_output" | tail -n +2 | awk '{print $1}' | grep -v "^$"))

	if [[ ${#profiles[@]} -eq 0 ]]; then
		log_warn "No Minikube profiles found to delete"
		exit 3
	fi

	log_info "Found ${#profiles[@]} profile(s) to delete:"
	for profile in "${profiles[@]}"; do
		log_info "  - $profile"
	done

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		log_debug "DRY RUN: Would delete ${#profiles[@]} profile(s)"
		return 0
	fi

	# Delete each profile
	local failed_deletions=()
	local successful_deletions=0

	for profile in "${profiles[@]}"; do
		log_info "Processing profile: $profile"
		if delete_profile "$profile" "$force"; then
			((successful_deletions++))
		else
			failed_deletions+=("$profile")
		fi
	done

	# Report results
	log_info "Deletion summary:"
	log_success "Successfully deleted: $successful_deletions profile(s)"

	if [[ ${#failed_deletions[@]} -gt 0 ]]; then
		log_error "Failed to delete ${#failed_deletions[@]} profile(s):"
		for failed_profile in "${failed_deletions[@]}"; do
			log_error "  - $failed_profile"
		done
		return 1
	fi

	return 0
}

# Function to purge all Minikube data
purge_minikube_data() {
	print_step "3" "Purging Minikube Data"

	log_warn "This will remove ALL Minikube configuration and cache data"
	log_info "This includes:"
	log_info "  - ~/.minikube directory"
	log_info "  - Minikube configuration files"
	log_info "  - Downloaded ISO images"
	log_info "  - Docker images and containers"

	if [[ "${AUTO_YES:-false}" != "true" ]]; then
		echo ""
		read -p "Do you want to purge all Minikube data? (yes/no): " -r
		echo ""

		case "$REPLY" in
		yes | YES | Yes)
			log_info "Purge confirmed by user"
			;;
		*)
			log_info "Purge cancelled by user"
			return 0
			;;
		esac
	fi

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		log_debug "DRY RUN: rm -rf ~/.minikube"
		return 0
	fi

	# Remove Minikube directory
	local minikube_dir="$HOME/.minikube"
	if [[ -d "$minikube_dir" ]]; then
		log_info "Removing Minikube directory: $minikube_dir"
		rm -rf "$minikube_dir" || {
			log_error "Failed to remove Minikube directory"
			return 1
		}
		log_success "Minikube directory removed successfully"
	else
		log_info "Minikube directory does not exist, nothing to purge"
	fi

	# Remove kubectl context entries for deleted clusters
	log_info "Cleaning up kubectl contexts..."
	if command_exists kubectl; then
		# Get all contexts that might be Minikube-related
		local contexts=$(kubectl config get-contexts -o name 2>/dev/null | grep -E "(minikube|$DEFAULT_CLUSTER_NAME)" || true)

		if [[ -n "$contexts" ]]; then
			for context in $contexts; do
				log_info "Removing kubectl context: $context"
				kubectl config delete-context "$context" >/dev/null 2>&1 || true
			done
		fi

		log_success "kubectl contexts cleaned up"
	fi

	log_success "Minikube data purge completed!"
}

# Function to display deletion summary
show_deletion_summary() {
	print_step "4" "Deletion Summary"

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		log_debug "DRY RUN: Summary would be displayed here"
		return 0
	fi

	log_success "Minikube cluster deletion completed!"
	echo ""
	echo -e "${WHITE}Next steps:${NC}"
	echo -e "  ${CYAN}• To create a new cluster, run the creation script${NC}"
	echo -e "  ${CYAN}• To verify deletion, run: minikube profile list${NC}"

	if [[ "${PURGE_DATA:-false}" == "true" ]]; then
		echo -e "  ${CYAN}• All Minikube data has been purged${NC}"
		echo -e "  ${CYAN}• Next cluster creation will download fresh components${NC}"
	fi
	echo ""
}

# Function to handle cleanup on script exit
cleanup() {
	local exit_code=$?
	if [[ $exit_code -ne 0 ]] && [[ "${DRY_RUN:-false}" != "true" ]]; then
		log_error "Script exited with error code $exit_code"
		log_info "Some clusters may not have been deleted completely"
		log_info "Check with: minikube profile list"
	fi
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
	# Set up signal handling
	trap cleanup EXIT

	# Parse command line arguments
	local profile_name=""
	local delete_all=false
	local list_only=false
	local force=false

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
		-y | --yes)
			AUTO_YES=true
			log_debug "Auto-confirmation enabled"
			shift
			;;
		-f | --force)
			force=true
			log_debug "Force mode enabled"
			shift
			;;
		-a | --all)
			delete_all=true
			log_debug "Delete all profiles mode enabled"
			shift
			;;
		-p | --purge)
			PURGE_DATA=true
			log_debug "Purge data mode enabled"
			shift
			;;
		-l | --list)
			list_only=true
			log_debug "List only mode enabled"
			shift
			;;
		--dry-run)
			DRY_RUN=true
			log_debug "Dry run mode enabled"
			shift
			;;
		-*)
			log_error "Unknown option: $1"
			log_info "Use --help for usage information"
			exit 1
			;;
		*)
			if [[ -z "$profile_name" ]]; then
				profile_name="$1"
				log_debug "Profile name set to: $profile_name"
			else
				log_error "Multiple profile names specified: '$profile_name' and '$1'"
				log_info "Please specify only one profile name"
				exit 1
			fi
			shift
			;;
		esac
	done

	# Set default profile name if not specified
	if [[ -z "$profile_name" ]] && [[ "$delete_all" == "false" ]]; then
		profile_name="$DEFAULT_CLUSTER_NAME"
		log_debug "Using default profile name: $profile_name"
	fi

	# Print script header
	print_section "Personal Website Minikube Cluster Deletion"

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		log_warn "DRY RUN MODE: No actual changes will be made"
	fi

	# Execute steps
	check_prerequisites

	# List profiles if requested
	if [[ "$list_only" == "true" ]]; then
		if list_profiles; then
			exit 0
		else
			exit 3
		fi
	fi

	# Show current profiles
	if ! list_profiles; then
		log_warn "No clusters found to delete"
		exit 3
	fi

	# Confirm deletion
	if [[ "$delete_all" == "true" ]]; then
		confirm_deletion "all" true

		if delete_all_profiles "$force"; then
			if [[ "${PURGE_DATA:-false}" == "true" ]]; then
				purge_minikube_data
			fi
		else
			log_error "Failed to delete all profiles"
			exit 5
		fi
	else
		confirm_deletion "$profile_name" false

		if delete_profile "$profile_name" "$force"; then
			if [[ "${PURGE_DATA:-false}" == "true" ]]; then
				purge_minikube_data
			fi
		else
			log_error "Failed to delete profile: $profile_name"
			exit 5
		fi
	fi

	show_deletion_summary
	log_success "Deletion process completed successfully!"
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
