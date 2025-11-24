#!/bin/bash
set -e

# Package Configuration
PKG_NAME="gephgui-wry-bin"
API_URL="https://api.github.com/repos/geph-official/gephgui-pkg/releases/latest"

# 1. Version Check
LOCAL_VER=$(grep -Po '^pkgver=\K.*' PKGBUILD)
UPSTREAM_VER=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$API_URL" | jq -r '.tag_name' | sed 's/^v//')

if [[ -z "$UPSTREAM_VER" || "$UPSTREAM_VER" == "null" ]]; then
    echo "Error: Failed to fetch upstream version."
    exit 1
fi

if [[ "$LOCAL_VER" == "$UPSTREAM_VER" ]]; then
    echo "::notice::Package $PKG_NAME is up to date ($LOCAL_VER)."
    echo "built=false" >> $GITHUB_OUTPUT
    exit 0
fi

echo "::group::Update Found: $LOCAL_VER -> $UPSTREAM_VER"

# 2. Update PKGBUILD
sed -i "s/^pkgver=.*/pkgver=${UPSTREAM_VER}/" PKGBUILD
sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD

# 3. Build
# Create non-root user for makepkg security compliance
useradd -m builduser
chown -R builduser:builduser .

# updpkgsums automatically calculates checksums for source files (including your .sh helper)
sudo -u builduser bash -c 'updpkgsums'
sudo -u builduser bash -c 'makepkg --skippgpcheck --noconfirm'

echo "built=true" >> $GITHUB_OUTPUT
echo "version=${UPSTREAM_VER}" >> $GITHUB_OUTPUT
echo "::endgroup::"
