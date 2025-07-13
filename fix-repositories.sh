#!/bin/bash

set -euxo pipefail

echo "=== [DEBUG] fix-repositories.sh: Script started ==="
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"

# Check if we're in a Debian Buster system
if [ -f /etc/os-release ]; then
    echo "OS info:"
    cat /etc/os-release | head -5
fi

echo "=== Fixing Debian Buster repositories ==="

# Replace sources.list completely with working archive URLs
echo 'deb http://archive.debian.org/debian buster main contrib non-free' > /etc/apt/sources.list
echo 'deb http://archive.debian.org/debian-security buster/updates main contrib non-free' >> /etc/apt/sources.list

echo "New sources.list content:"
cat /etc/apt/sources.list

# Remove any additional source files that might interfere
echo "Removing conflicting source files..."
rm -f /etc/apt/sources.list.d/* 2>/dev/null || true

# Disable validity checks for archived repositories
echo "Setting up apt configuration..."
mkdir -p /etc/apt/apt.conf.d/
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until
echo 'Acquire::Check-Date "false";' >> /etc/apt/apt.conf.d/99no-check-valid-until

echo "Apt configuration:"
cat /etc/apt/apt.conf.d/99no-check-valid-until

# Clean apt cache
echo "Cleaning apt cache..."
rm -rf /var/lib/apt/lists/*

echo "=== Testing repository fix ==="
if apt-get update; then
    echo "SUCCESS: Repository fix worked!"
    apt-get install -y autoconf automake libtool pkg-config ragel
    echo "SUCCESS: Dependencies installed!"
else
    echo "FAILED: Repository fix didn't work"
    exit 1
fi

echo "=== Repository fix completed successfully ===" 