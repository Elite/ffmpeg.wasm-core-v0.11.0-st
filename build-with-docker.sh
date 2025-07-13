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
    echo '[DEBUG] Docker container started, about to run fix-repositories.sh...'
    cd /src
    chmod +x ./fix-repositories.sh
    ./fix-repositories.sh

    echo 'Now running build script...'
    bash ./build.sh \"\$@\"
  " "$@"
