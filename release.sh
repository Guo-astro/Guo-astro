#!/usr/bin/env bash
# release.sh — Simple release script for github_profile_makeover.sh
# -----------------------------------------------------------------------------
# Usage:
#   ./release.sh patch    # Increment patch version (1.0.0 -> 1.0.1)
#   ./release.sh minor    # Increment minor version (1.0.0 -> 1.1.0)
#   ./release.sh major    # Increment major version (1.0.0 -> 2.0.0)
# -----------------------------------------------------------------------------

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$*"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$*"; }
success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$*"; }

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not in a git repository"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    error "You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Check if we have a version argument
if [[ $# -ne 1 ]]; then
    error "Usage: $0 {patch|minor|major}"
    exit 1
fi

VERSION_TYPE="$1"

# Validate version type
if [[ ! "$VERSION_TYPE" =~ ^(patch|minor|major)$ ]]; then
    error "Invalid version type. Use: patch, minor, or major"
    exit 1
fi

# Get current version from git tags
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
info "Current version: $CURRENT_VERSION"

# Remove 'v' prefix if present
CURRENT_VERSION=${CURRENT_VERSION#v}

# Parse version components
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]:-0}
MINOR=${VERSION_PARTS[1]:-0}
PATCH=${VERSION_PARTS[2]:-0}

# Calculate new version
case "$VERSION_TYPE" in
    "major")
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_PATCH=0
        ;;
    "minor")
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_PATCH=0
        ;;
    "patch")
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="v${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
info "New version will be: $NEW_VERSION"

# Confirm with user
read -p "Do you want to create release $NEW_VERSION? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warn "Release cancelled"
    exit 0
fi

# Update version in script header
info "Updating version in github_profile_makeover.sh..."
sed -i.bak "s/# github_profile_makeover.sh —/# github_profile_makeover.sh — $NEW_VERSION —/" github_profile_makeover.sh
rm github_profile_makeover.sh.bak

# Commit changes
info "Committing version update..."
git add github_profile_makeover.sh
git commit -m "chore: bump version to $NEW_VERSION"

# Create and push tag
info "Creating and pushing tag $NEW_VERSION..."
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION

## Changes
- Version bump to $NEW_VERSION
- Updated profile README template with latest packages
- Enhanced GitHub profile automation

## Usage
\`\`\`bash
# Dry run (shows what would happen)
./github_profile_makeover.sh

# Apply changes
./github_profile_makeover.sh --apply
\`\`\`"

# Push commits and tags
info "Pushing to remote..."
git push origin main
git push origin "$NEW_VERSION"

success "Release $NEW_VERSION created successfully!"
success "🎉 Your GitHub profile makeover script has been released!"

# Show next steps
echo
info "Next steps:"
echo "  1. Update your profile: ./github_profile_makeover.sh --apply"
echo "  2. Check your GitHub profile: https://github.com/$(git config user.name || echo 'YOUR_USERNAME')"
echo "  3. Share your awesome profile with the world! 🌟"
