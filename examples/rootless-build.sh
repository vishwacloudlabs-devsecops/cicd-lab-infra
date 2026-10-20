#!/usr/bin/env bash
# Optional: run on an agent with an already configured rootless BuildKit daemon.
set -euo pipefail
: "${BUILDKIT_HOST:?Set the rootless BuildKit socket address}"
: "${IMAGE_REF:?Set a registry/repository:unique-tag}"
buildctl --addr "$BUILDKIT_HOST" build \
  --frontend dockerfile.v0 \
  --local context=. --local dockerfile=. \
  --output "type=image,name=$IMAGE_REF,push=true"
