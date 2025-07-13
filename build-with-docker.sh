#!/bin/bash

set -euxo pipefail

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
    set -euxo pipefail
    echo 'Fixing Debian Buster repositories...'
    echo 'deb http://archive.debian.org/debian buster main contrib non-free' > /etc/apt/sources.list
    echo 'deb http://archive.debian.org/debian-security buster/updates main contrib non-free' >> /etc/apt/sources.list
    rm -f /etc/apt/sources.list.d/* 2>/dev/null || true
    mkdir -p /etc/apt/apt.conf.d/
    echo 'Acquire::Check-Valid-Until \"false\";' > /etc/apt/apt.conf.d/99no-check-valid-until
    echo 'Acquire::Check-Date \"false\";' >> /etc/apt/apt.conf.d/99no-check-valid-until
    rm -rf /var/lib/apt/lists/*
    apt-get update
    cd /src
    bash ./build.sh \"\$@\"
  " "$@"
