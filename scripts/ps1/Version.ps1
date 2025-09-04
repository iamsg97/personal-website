# Semantic Versioning Script for Portfolio App (PowerShell)
# Usage: ./scripts/ps1/Version.ps1 [major|minor|patch] [-DryRun] [-NoGit] [-NoDocker] [-Help]

param(
    [Parameter(Position=0)]
    [ValidateSet('major','minor','patch')]
    [string]$VersionType,
    [switch]$DryRun,
    [switch]$NoGit,
    [switch]$NoDocker,
    [switch]$Help
)

# Colors for output (PowerShell-friendly)
function Print-Info($msg)    { Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Print-Success($msg) { Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
function Print-Warning($msg) { Write-Host "[WARNING] $msg" -ForegroundColor Yellow }
function Print-Error($msg)   { Write-Host "[ERROR] $msg" -ForegroundColor Red }

$VERSION_FILE = "VERSION"
$script:CURRENT_VERSION = ""
$script:NEW_VERSION = ""

function Get-CurrentVersion {
    if (Test-Path $VERSION_FILE) {
        $script:CURRENT_VERSION = (Get-Content $VERSION_FILE -First 1).Trim()
    } else {
        $script:CURRENT_VERSION = "0.0.0"
        Set-Content $VERSION_FILE $script:CURRENT_VERSION
        Print-Warning "No version file found. Created with version $script:CURRENT_VERSION"
    }
}

function Validate-Version($version) {
    if ($version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
        Print-Error "Invalid version format: $version. Expected format: MAJOR.MINOR.PATCH"
        exit 1
    }
}

function Increment-Version($type) {
    $parts = $script:CURRENT_VERSION.Split('.')
    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]

    switch ($type) {
        'major' {
            $major++
            $minor = 0
            $patch = 0
        }
        'minor' {
            $minor++
            $patch = 0
        }
        'patch' {
            $patch++
        }
        default {
            Print-Error "Invalid version type: $type. Use: major, minor, or patch"
            exit 1
        }
    }

    $script:NEW_VERSION = "$major.$minor.$patch"
}

function Update-VersionFiles {
    Print-Info "Updating version files..."

    # Update VERSION file
    Set-Content $VERSION_FILE $script:NEW_VERSION

    # Update package.json
    if (Test-Path "package.json") {
        $pkg = Get-Content "package.json" -Raw
        $pkg = $pkg -replace '"version": "[^"]*"', "`"version`": `"$($script:NEW_VERSION)`""
        Set-Content "package.json" $pkg
        Print-Success "Updated package.json to version $($script:NEW_VERSION)"
    }

    # Update k8s/base/kustomization.yaml
    $baseKustom = "k8s/base/kustomization.yaml"
    if (Test-Path $baseKustom) {
        $content = Get-Content $baseKustom -Raw
        $content = $content -replace 'version: v.*', "version: v$($script:NEW_VERSION)"
        $content = $content -replace 'newTag: v.*', "newTag: v$($script:NEW_VERSION)"
        Set-Content $baseKustom $content
        Print-Success "Updated Kubernetes base kustomization to version v$($script:NEW_VERSION)"
    }

    # Update k8s/overlays/production/kustomization.yaml
    $prodKustom = "k8s/overlays/production/kustomization.yaml"
    if (Test-Path $prodKustom) {
        $content = Get-Content $prodKustom -Raw
        $content = $content -replace 'newTag: v.*', "newTag: v$($script:NEW_VERSION)"
        Set-Content $prodKustom $content
        Print-Success "Updated production overlay to version v$($script:NEW_VERSION)"
    }

    Print-Success "All version files updated to $($script:NEW_VERSION)"
}

function Create-GitTag {
    $gitExists = (Get-Command git -ErrorAction SilentlyContinue)
    if ($gitExists -and (Test-Path ".git")) {
        Print-Info "Creating git tag..."
        git add .
        git commit -m "chore: bump version to v$($script:NEW_VERSION)"
        git tag -a "v$($script:NEW_VERSION)" -m "Release version v$($script:NEW_VERSION)"
        Print-Success "Created git tag v$($script:NEW_VERSION)"
        Print-Info "Push changes with: git push origin main && git push origin v$($script:NEW_VERSION)"
    } else {
        Print-Warning "Not a git repository or git not installed. Skipping git tag creation."
    }
}

function Build-DockerImage {
    Print-Info "Building Docker image..."
    $image_name = "iamsg97-personal-website"
    $image_tag = "v$($script:NEW_VERSION)"
    try {
        docker build -t "${image_name}:${image_tag}" -t "${image_name}:latest" .
        Print-Success "Built Docker image: ${image_name}:${image_tag}"
        Print-Info "Push image with: docker push ${image_name}:${image_tag}"
    } catch {
        Print-Error "Docker build failed: $_"
    }
}

function Show-Usage {
    Write-Host "Usage: ./scripts/ps1/Version.ps1 [major|minor|patch] [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -DryRun      Show what would be done without making changes"
    Write-Host "  -NoGit       Skip git operations"
    Write-Host "  -NoDocker    Skip Docker build"
    Write-Host "  -Help        Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  ./scripts/ps1/Version.ps1 patch              # Increment patch version (1.0.0 -> 1.0.1)"
    Write-Host "  ./scripts/ps1/Version.ps1 minor              # Increment minor version (1.0.1 -> 1.1.0)"
    Write-Host "  ./scripts/ps1/Version.ps1 major              # Increment major version (1.1.0 -> 2.0.0)"
    Write-Host "  ./scripts/ps1/Version.ps1 patch -DryRun      # Show what would happen"
}

# Main execution
if ($Help -or !$VersionType) {
    Show-Usage
    exit 0
}

Get-CurrentVersion
Validate-Version $script:CURRENT_VERSION
Increment-Version $VersionType

Print-Info "Current version: $($script:CURRENT_VERSION)"
Print-Info "New version: $($script:NEW_VERSION)"

if ($DryRun) {
    Print-Warning "DRY RUN MODE - No changes will be made"
    Print-Info "Would update version from $($script:CURRENT_VERSION) to $($script:NEW_VERSION)"
    exit 0
}

$confirmation = Read-Host "Continue with version bump? (y/N)"
if ($confirmation -notmatch '^[Yy]$') {
    Print-Info "Version bump cancelled"
    exit 0
}

Update-VersionFiles
if (-not $NoGit) { Create-GitTag }
if (-not $NoDocker) { Build-DockerImage }

Print-Success "Version bump completed successfully!"
Print-Info "New version: v$($script:NEW_VERSION)"
