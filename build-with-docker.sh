#!/bin/bash

set -euo pipefail

EM_VERSION=${EM_VERSION:-2.0.8}

docker pull emscripten/emsdk:$EM_VERSION
docker run \
  --rm \
  -v $PWD:/src \
  -v $PWD/wasm/cache:/emsdk_portable/.data/cache/wasm \
  -e FFMPEG_ST=${FFMPEG_ST:-no} \
  emscripten/emsdk:$EM_VERSION \
  bash -c '
    # Fix Debian Buster repositories (end-of-life) 
    if grep -q "buster" /etc/apt/sources.list 2>/dev/null; then
      echo "Fixing Debian Buster repositories..."
      echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list
      echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list
      echo '\''Acquire::Check-Valid-Until "false";'\'' > /etc/apt/apt.conf.d/99no-check-valid-until
    fi
    
    # Now run the build script
    bash ./build.sh "$@"
  ' -- "$@"
