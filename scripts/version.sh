#!/bin/bash

# Semantic Versioning Script for Portfolio App
# Usage: ./scripts/version.sh [major|minor|patch]

set -e

# Configuration
VERSION_FILE="VERSION"
CURRENT_VERSION=""
NEW_VERSION=""

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

# Function to get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        CURRENT_VERSION=$(cat "$VERSION_FILE")
    else
        CURRENT_VERSION="0.0.0"
        echo "$CURRENT_VERSION" > "$VERSION_FILE"
        print_warning "No version file found. Created with version $CURRENT_VERSION"
    fi
}

# Function to validate version format
validate_version() {
    if [[ ! $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $1. Expected format: MAJOR.MINOR.PATCH"
        exit 1
    fi
}

# Function to increment version
increment_version() {
    local version_type=$1
    local version=$CURRENT_VERSION
    
    IFS='.' read -ra VERSION_PARTS <<< "$version"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}
    
    case $version_type in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
        *)
            print_error "Invalid version type: $version_type. Use: major, minor, or patch"
            exit 1
            ;;
    esac
    
    NEW_VERSION="$major.$minor.$patch"
}

# Function to update version in files
update_version_files() {
    print_info "Updating version files..."
    
    # Update VERSION file
    echo "$NEW_VERSION" > "$VERSION_FILE"
    
    # Update package.json
    if [[ -f "package.json" ]]; then
        # Use sed to update package.json version manually
        sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" package.json
        print_success "Updated package.json to version $NEW_VERSION"
    fi
    
    # Update Kubernetes base kustomization
    if [[ -f "k8s/base/kustomization.yaml" ]]; then
        sed -i.bak "s/version: v.*/version: v$NEW_VERSION/" k8s/base/kustomization.yaml
        sed -i.bak "s/newTag: v.*/newTag: v$NEW_VERSION/" k8s/base/kustomization.yaml
        rm k8s/base/kustomization.yaml.bak 2>/dev/null || true
        print_success "Updated Kubernetes base kustomization to version v$NEW_VERSION"
    fi
    
    # Update production overlay
    if [[ -f "k8s/overlays/production/kustomization.yaml" ]]; then
        sed -i.bak "s/newTag: v.*/newTag: v$NEW_VERSION/" k8s/overlays/production/kustomization.yaml
        rm k8s/overlays/production/kustomization.yaml.bak 2>/dev/null || true
        print_success "Updated production overlay to version v$NEW_VERSION"
    fi
    
    print_success "All version files updated to $NEW_VERSION"
}

# Function to create git tag
create_git_tag() {
    if command -v git &> /dev/null && [[ -d ".git" ]]; then
        print_info "Creating git tag..."
        git add .
        git commit -m "chore: bump version to v$NEW_VERSION" || true
        git tag -a "v$NEW_VERSION" -m "Release version v$NEW_VERSION"
        print_success "Created git tag v$NEW_VERSION"
        print_info "Push changes with: git push origin main && git push origin v$NEW_VERSION"
    else
        print_warning "Not a git repository or git not installed. Skipping git tag creation."
    fi
}

# Function to build and tag Docker image
build_docker_image() {
    print_info "Building Docker image..."
    
    local image_name="portfolio-app"
    local image_tag="v$NEW_VERSION"
    
    # Build the image
    docker build -t "$image_name:$image_tag" -t "$image_name:latest" .
    
    print_success "Built Docker image: $image_name:$image_tag"
    print_info "Push image with: docker push $image_name:$image_tag"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [major|minor|patch] [options]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without making changes"
    echo "  --no-git     Skip git operations"
    echo "  --no-docker  Skip Docker build"
    echo "  --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 patch              # Increment patch version (1.0.0 -> 1.0.1)"
    echo "  $0 minor              # Increment minor version (1.0.1 -> 1.1.0)"
    echo "  $0 major              # Increment major version (1.1.0 -> 2.0.0)"
    echo "  $0 patch --dry-run    # Show what would happen"
}

# Main function
main() {
    local version_type=""
    local dry_run=false
    local skip_git=false
    local skip_docker=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            major|minor|patch)
                version_type=$1
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --no-git)
                skip_git=true
                shift
                ;;
            --no-docker)
                skip_docker=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate input
    if [[ -z "$version_type" ]]; then
        print_error "Version type is required"
        show_usage
        exit 1
    fi
    
    # Get current version
    get_current_version
    validate_version "$CURRENT_VERSION"
    
    # Calculate new version
    increment_version "$version_type"
    
    print_info "Current version: $CURRENT_VERSION"
    print_info "New version: $NEW_VERSION"
    
    if [[ "$dry_run" == true ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
        print_info "Would update version from $CURRENT_VERSION to $NEW_VERSION"
        exit 0
    fi
    
    # Confirm with user
    read -p "Continue with version bump? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Version bump cancelled"
        exit 0
    fi
    
    # Update version files
    update_version_files
    
    # Git operations
    if [[ "$skip_git" != true ]]; then
        create_git_tag
    fi
    
    # Docker operations
    if [[ "$skip_docker" != true ]]; then
        build_docker_image
    fi
    
    print_success "Version bump completed successfully! 🎉"
    print_info "New version: v$NEW_VERSION"
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
