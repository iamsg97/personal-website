#!/bin/bash

# Portfolio App Deployment Script
# Usage: ./scripts/deploy.sh [environment] [action]
# Environment: development, staging, production
# Action: deploy, delete, diff, dry-run

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/VERSION"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [environment] [action] [options]"
    echo ""
    echo "Environments:"
    echo "  development  Deploy to development environment"
    echo "  staging      Deploy to staging environment"
    echo "  production   Deploy to production environment"
    echo ""
    echo "Actions:"
    echo "  deploy       Apply the Kubernetes manifests"
    echo "  delete       Delete the deployment"
    echo "  diff         Show differences that would be applied"
    echo "  dry-run      Show what would be deployed"
    echo "  status       Show current deployment status"
    echo "  detailed     Show detailed status with troubleshooting info"
    echo "  logs         Show application logs"
    echo "  describe     Describe Kubernetes resources"
    echo "  debug        Debug common deployment issues"
    echo ""
    echo "Log Options (for logs action):"
    echo "  -f, --follow    Follow log output"
    echo "  -l, --lines N   Show last N lines (default: 50)"
    echo "  -p, --pod NAME  Show logs for specific pod"
    echo ""
    echo "Describe Options (for describe action):"
    echo "  pods         Describe all pods"
    echo "  deployments  Describe all deployments"
    echo "  services     Describe all services"
    echo "  ingress      Describe ingress resources"
    echo "  all          Describe all resources (default)"
    echo ""
    echo "Examples:"
    echo "  $0 development deploy"
    echo "  $0 production dry-run"
    echo "  $0 staging status"
    echo "  $0 development detailed"
    echo "  $0 production logs -f"
    echo "  $0 development logs -l 100 -p my-pod"
    echo "  $0 production describe pods"
    echo "  $0 staging debug"
}

# Function to check prerequisites
check_prerequisites() {
    # Check if kubectl is available
    if ! command -v kubectl &>/dev/null; then
        print_error "kubectl is not installed or not in PATH"
        print_info "Install kubectl: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi

    # Check if kubectl can connect to cluster (only for actions that need it)
    if [[ "$ACTION" != "dry-run" ]] && ! kubectl cluster-info &>/dev/null; then
        print_error "kubectl cannot connect to Kubernetes cluster"
        print_info "Make sure you have a valid kubeconfig and cluster is running"
        print_info "For local development, try: minikube start or kind create cluster"
        exit 1
    fi

    # Check if the kustomization file exists
    local kustomize_file="$PROJECT_ROOT/k8s/overlays/$ENVIRONMENT/kustomization.yaml"
    if [[ ! -f "$kustomize_file" ]]; then
        print_error "Kustomization file not found: $kustomize_file"
        exit 1
    fi
}

# Function to get current version
get_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE" | tr -d '\n'
    else
        echo "latest"
    fi
}

# Function to build manifests
build_manifests() {
    local overlay_path="$PROJECT_ROOT/k8s/overlays/$ENVIRONMENT"
    print_info "Building manifests for $ENVIRONMENT environment..."
    kubectl kustomize "$overlay_path"
}

# Function to deploy
deploy() {
    print_info "Deploying to $ENVIRONMENT environment..."
    local overlay_path="$PROJECT_ROOT/k8s/overlays/$ENVIRONMENT"
    kubectl apply -k "$overlay_path"
    print_success "Deployment completed successfully!"

    # Show deployment status
    local namespace="portfolio-$ENVIRONMENT"
    if [[ "$ENVIRONMENT" == "development" ]]; then
        namespace="portfolio-dev"
    elif [[ "$ENVIRONMENT" == "production" ]]; then
        namespace="portfolio-prod"
    fi

    print_info "Checking deployment status..."
    kubectl get pods -n "$namespace" -l app=portfolio-app
}

# Function to delete deployment
delete_deployment() {
    print_warning "This will delete the entire $ENVIRONMENT deployment!"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deleting $ENVIRONMENT deployment..."
        local overlay_path="$PROJECT_ROOT/k8s/overlays/$ENVIRONMENT"
        kubectl delete -k "$overlay_path"
        print_success "Deployment deleted successfully!"
    else
        print_info "Deletion cancelled."
    fi
}

# Function to show diff
show_diff() {
    print_info "Showing differences for $ENVIRONMENT environment..."
    local overlay_path="$PROJECT_ROOT/k8s/overlays/$ENVIRONMENT"
    kubectl diff -k "$overlay_path" 2>/dev/null || true
}

# Function to show status
show_status() {
    local namespace="portfolio-$ENVIRONMENT"
    if [[ "$ENVIRONMENT" == "development" ]]; then
        namespace="portfolio-dev"
    elif [[ "$ENVIRONMENT" == "production" ]]; then
        namespace="portfolio-prod"
    fi

    print_info "Deployment status for $ENVIRONMENT environment:"
    echo ""

    print_info "Pods:"
    kubectl get pods -n "$namespace" -l app=portfolio-app 2>/dev/null || print_warning "No pods found or namespace doesn't exist"

    echo ""
    print_info "Services:"
    kubectl get services -n "$namespace" -l app=portfolio-app 2>/dev/null || print_warning "No services found or namespace doesn't exist"

    echo ""
    print_info "Ingress:"
    kubectl get ingress -n "$namespace" -l app=portfolio-app 2>/dev/null || print_warning "No ingress found or namespace doesn't exist"
}

# Function to show detailed status with troubleshooting
show_detailed_status() {
    local namespace="portfolio-$ENVIRONMENT"
    if [[ "$ENVIRONMENT" == "development" ]]; then
        namespace="portfolio-dev"
    elif [[ "$ENVIRONMENT" == "production" ]]; then
        namespace="portfolio-prod"
    fi

    print_info "=== DETAILED STATUS FOR $ENVIRONMENT ENVIRONMENT ==="
    echo ""

    # Check namespace
    print_info "Namespace:"
    kubectl get namespace "$namespace" 2>/dev/null || print_warning "Namespace $namespace doesn't exist"
    echo ""

    # Check all resources with portfolio-app label
    print_info "All Resources:"
    kubectl get all -n "$namespace" -l app=portfolio-app 2>/dev/null || print_warning "No resources found"
    echo ""

    # Check pods in detail
    print_info "Pod Details:"
    kubectl get pods -n "$namespace" -l app=portfolio-app -o wide 2>/dev/null || print_warning "No pods found"
    echo ""

    # Check deployments
    print_info "Deployment Status:"
    kubectl get deployments -n "$namespace" -l app=portfolio-app 2>/dev/null || print_warning "No deployments found"
    echo ""

    # Check replica sets
    print_info "ReplicaSets:"
    kubectl get replicasets -n "$namespace" -l app=portfolio-app 2>/dev/null || print_warning "No replica sets found"
    echo ""

    # Check services
    print_info "Service Details:"
    kubectl get services -n "$namespace" -l app=portfolio-app -o wide 2>/dev/null || print_warning "No services found"
    echo ""

    # Check ingress
    print_info "Ingress Details:"
    kubectl get ingress -n "$namespace" -l app=portfolio-app -o wide 2>/dev/null || print_warning "No ingress found"
    echo ""

    # Check configmaps
    print_info "ConfigMaps:"
    kubectl get configmaps -n "$namespace" -l app=portfolio-app 2>/dev/null || print_warning "No configmaps found"
    echo ""

    # Check events
    print_info "Recent Events:"
    kubectl get events -n "$namespace" --sort-by='.lastTimestamp' --field-selector reason!=Pulled,reason!=Created,reason!=Started 2>/dev/null | tail -10 || print_warning "No events found"
    echo ""

    # Check pod status and issues
    local pods=$(kubectl get pods -n "$namespace" -l app=portfolio-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    if [[ -n "$pods" ]]; then
        for pod in $pods; do
            local status=$(kubectl get pod "$pod" -n "$namespace" -o jsonpath='{.status.phase}' 2>/dev/null)
            local ready=$(kubectl get pod "$pod" -n "$namespace" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)

            print_info "Pod $pod Status: $status, Ready: $ready"

            # If pod is not running or ready, show more details
            if [[ "$status" != "Running" ]] || [[ "$ready" != "True" ]]; then
                print_warning "Pod $pod has issues. Describing pod:"
                kubectl describe pod "$pod" -n "$namespace" | tail -20
                echo ""
            fi
        done
    fi
}

# Function to show logs
show_logs() {
    local namespace="portfolio-$ENVIRONMENT"
    if [[ "$ENVIRONMENT" == "development" ]]; then
        namespace="portfolio-dev"
    elif [[ "$ENVIRONMENT" == "production" ]]; then
        namespace="portfolio-prod"
    fi

    local follow_flag=""
    local lines="50"
    local pod_name=""

    # Parse additional arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        -f | --follow)
            follow_flag="-f"
            shift
            ;;
        -l | --lines)
            lines="$2"
            shift 2
            ;;
        -p | --pod)
            pod_name="$2"
            shift 2
            ;;
        *)
            shift
            ;;
        esac
    done

    print_info "Showing logs for $ENVIRONMENT environment..."

    if [[ -n "$pod_name" ]]; then
        # Show logs for specific pod
        print_info "Logs for pod: $pod_name"
        kubectl logs -n "$namespace" "$pod_name" --tail="$lines" $follow_flag 2>/dev/null || print_error "Failed to get logs for pod $pod_name"
    else
        # Show logs for all pods with portfolio-app label
        local pods=$(kubectl get pods -n "$namespace" -l app=portfolio-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)

        if [[ -z "$pods" ]]; then
            print_warning "No pods found in namespace $namespace"
            return 1
        fi

        for pod in $pods; do
            print_info "=== Logs for pod: $pod ==="
            kubectl logs -n "$namespace" "$pod" --tail="$lines" $follow_flag 2>/dev/null || print_error "Failed to get logs for pod $pod"
            echo ""
        done
    fi
}

# Function to describe resources
describe_resources() {
    local namespace="portfolio-$ENVIRONMENT"
    if [[ "$ENVIRONMENT" == "development" ]]; then
        namespace="portfolio-dev"
    elif [[ "$ENVIRONMENT" == "production" ]]; then
        namespace="portfolio-prod"
    fi

    local resource_type="${1:-all}"

    print_info "Describing $resource_type resources for $ENVIRONMENT environment..."
    echo ""

    case "$resource_type" in
    "pod" | "pods")
        local pods=$(kubectl get pods -n "$namespace" -l app=portfolio-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
        for pod in $pods; do
            print_info "=== Pod: $pod ==="
            kubectl describe pod "$pod" -n "$namespace"
            echo ""
        done
        ;;
    "deployment" | "deployments")
        local deployments=$(kubectl get deployments -n "$namespace" -l app=portfolio-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
        for deployment in $deployments; do
            print_info "=== Deployment: $deployment ==="
            kubectl describe deployment "$deployment" -n "$namespace"
            echo ""
        done
        ;;
    "service" | "services")
        local services=$(kubectl get services -n "$namespace" -l app=portfolio-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
        for service in $services; do
            print_info "=== Service: $service ==="
            kubectl describe service "$service" -n "$namespace"
            echo ""
        done
        ;;
    "ingress")
        local ingresses=$(kubectl get ingress -n "$namespace" -l app=portfolio-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
        for ingress in $ingresses; do
            print_info "=== Ingress: $ingress ==="
            kubectl describe ingress "$ingress" -n "$namespace"
            echo ""
        done
        ;;
    "all" | *)
        print_info "Describing all resources..."
        describe_resources "pods"
        describe_resources "deployments"
        describe_resources "services"
        describe_resources "ingress"
        ;;
    esac
}

# Function to debug common issues
debug_issues() {
    local namespace="portfolio-$ENVIRONMENT"
    if [[ "$ENVIRONMENT" == "development" ]]; then
        namespace="portfolio-dev"
    elif [[ "$ENVIRONMENT" == "production" ]]; then
        namespace="portfolio-prod"
    fi

    print_info "=== DEBUGGING COMMON ISSUES ==="
    echo ""

    # Check if namespace exists
    print_info "1. Checking namespace..."
    if ! kubectl get namespace "$namespace" &>/dev/null; then
        print_error "Namespace $namespace does not exist!"
        print_info "Create it with: kubectl create namespace $namespace"
        echo ""
    else
        print_success "Namespace $namespace exists"
    fi

    # Check if any pods exist
    print_info "2. Checking for pods..."
    local pod_count=$(kubectl get pods -n "$namespace" -l app=portfolio-app --no-headers 2>/dev/null | wc -l)
    if [[ "$pod_count" -eq 0 ]]; then
        print_error "No pods found!"
        print_info "Check if deployment was successful with: kubectl get deployments -n $namespace"
    else
        print_success "Found $pod_count pod(s)"
    fi

    # Check pod status
    print_info "3. Checking pod status..."
    local pods=$(kubectl get pods -n "$namespace" -l app=portfolio-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    for pod in $pods; do
        local status=$(kubectl get pod "$pod" -n "$namespace" -o jsonpath='{.status.phase}' 2>/dev/null)
        local ready=$(kubectl get pod "$pod" -n "$namespace" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)

        if [[ "$status" != "Running" ]] || [[ "$ready" != "True" ]]; then
            print_error "Pod $pod is not healthy (Status: $status, Ready: $ready)"

            # Check common issues
            print_info "Checking for common issues in pod $pod:"

            # Image pull issues
            local image_pull_errors=$(kubectl describe pod "$pod" -n "$namespace" | grep -i "failed to pull\|image pull\|ErrImagePull\|ImagePullBackOff" || true)
            if [[ -n "$image_pull_errors" ]]; then
                print_error "Image pull issue detected:"
                echo "$image_pull_errors"
            fi

            # Resource constraints
            local resource_errors=$(kubectl describe pod "$pod" -n "$namespace" | grep -i "insufficient\|exceeded\|resource" || true)
            if [[ -n "$resource_errors" ]]; then
                print_error "Resource constraint detected:"
                echo "$resource_errors"
            fi

            # Health check failures
            local health_errors=$(kubectl describe pod "$pod" -n "$namespace" | grep -i "liveness\|readiness\|health check" || true)
            if [[ -n "$health_errors" ]]; then
                print_error "Health check issue detected:"
                echo "$health_errors"
            fi

        else
            print_success "Pod $pod is healthy"
        fi
    done

    # Check service endpoints
    print_info "4. Checking service endpoints..."
    local services=$(kubectl get services -n "$namespace" -l app=portfolio-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    for service in $services; do
        local endpoints=$(kubectl get endpoints "$service" -n "$namespace" -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null)
        if [[ -z "$endpoints" ]]; then
            print_error "Service $service has no endpoints!"
            print_info "Check if pod labels match service selector"
        else
            print_success "Service $service has endpoints: $endpoints"
        fi
    done

    # Check ingress
    print_info "5. Checking ingress..."
    local ingresses=$(kubectl get ingress -n "$namespace" -l app=portfolio-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    for ingress in $ingresses; do
        local ingress_ip=$(kubectl get ingress "$ingress" -n "$namespace" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [[ -z "$ingress_ip" ]]; then
            print_warning "Ingress $ingress has no external IP assigned yet"
            print_info "This is normal for new ingresses. Check ingress controller status."
        else
            print_success "Ingress $ingress has IP: $ingress_ip"
        fi
    done

    echo ""
    print_info "=== DEBUGGING COMPLETE ==="
}

# Parse arguments
ENVIRONMENT="${1:-}"
ACTION="${2:-deploy}"

# Validate arguments
if [[ -z "$ENVIRONMENT" ]]; then
    print_error "Environment is required"
    show_usage
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    show_usage
    exit 1
fi

if [[ ! "$ACTION" =~ ^(deploy|delete|diff|dry-run|status|detailed|logs|describe|debug)$ ]]; then
    print_error "Invalid action: $ACTION"
    show_usage
    exit 1
fi

# Main execution
print_info "Portfolio App Deployment Script"
print_info "Environment: $ENVIRONMENT"
print_info "Action: $ACTION"
print_info "Version: $(get_version)"
echo ""

# Check prerequisites
check_prerequisites

# Execute action
case "$ACTION" in
"deploy")
    deploy
    ;;
"delete")
    delete_deployment
    ;;
"diff")
    show_diff
    ;;
"dry-run")
    print_info "Dry run - showing manifests that would be deployed:"
    echo ""
    build_manifests
    ;;
"status")
    show_status
    ;;
"detailed")
    show_detailed_status
    ;;
"logs")
    shift 2 # Remove environment and action from arguments
    show_logs "$@"
    ;;
"describe")
    shift 2 # Remove environment and action from arguments
    describe_resources "$1"
    ;;
"debug")
    debug_issues
    ;;
esac
