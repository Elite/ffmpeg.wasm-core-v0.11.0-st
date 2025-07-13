#!/bin/bash

set -euo pipefail

EM_VERSION=${EM_VERSION:-2.0.8}

docker pull emscripten/emsdk:$EM_VERSION
docker run \
  --rm \
  --user root \
  -v $PWD:/src \
  -v $PWD/wasm/cache:/emsdk_portable/.data/cache/wasm \
  -e FFMPEG_ST=${FFMPEG_ST:-no} \
  emscripten/emsdk:$EM_VERSION \
  /bin/bash -c "
    echo 'Starting container as root user...'
    echo 'Fixing Debian Buster repositories...'
    
    # Replace sources.list completely
    echo 'deb http://archive.debian.org/debian buster main contrib non-free' > /etc/apt/sources.list
    echo 'deb http://archive.debian.org/debian-security buster/updates main contrib non-free' >> /etc/apt/sources.list
    
    # Remove any additional source files that might interfere
    rm -f /etc/apt/sources.list.d/* 2>/dev/null || true
    
    # Disable validity checks for archived repositories
    mkdir -p /etc/apt/apt.conf.d/
    echo 'Acquire::Check-Valid-Until \"false\";' > /etc/apt/apt.conf.d/99no-check-valid-until
    echo 'Acquire::Check-Date \"false\";' >> /etc/apt/apt.conf.d/99no-check-valid-until
    
    # Clean apt cache and update
    rm -rf /var/lib/apt/lists/*
    
    echo 'Repository fix complete. Testing with apt-get update...'
    apt-get update && echo 'apt-get update SUCCESS!' || echo 'apt-get update FAILED!'
    
    echo 'Now running build script...'
    cd /src
    bash ./build.sh \"\$@\"
  " "$@"
