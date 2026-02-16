#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults (match Dockerfile ARG defaults)
CUDA_VERSION="13.1.1"
CUDA_SAMPLES_VERSION=""
UBUNTU_VERSION="24.04"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --cuda-version)      CUDA_VERSION="$2";         shift 2 ;;
        --samples-version)   CUDA_SAMPLES_VERSION="$2"; shift 2 ;;
        --ubuntu-version)    UBUNTU_VERSION="$2";        shift 2 ;;
        -h|--help)
            echo "Usage: $0 [--cuda-version X] [--samples-version X] [--ubuntu-version X]"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Default samples version to major.minor of CUDA version if not explicitly set
if [[ -z "${CUDA_SAMPLES_VERSION}" ]]; then
    CUDA_SAMPLES_VERSION="$(echo "${CUDA_VERSION}" | cut -d. -f1,2)"
fi

TAG="cuda-samples:cuda${CUDA_VERSION}-samples${CUDA_SAMPLES_VERSION}-ubuntu${UBUNTU_VERSION}"

echo "Building ${TAG} ..."

docker build \
    --build-arg CUDA_VERSION="${CUDA_VERSION}" \
    --build-arg CUDA_SAMPLES_VERSION="${CUDA_SAMPLES_VERSION}" \
    --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" \
    -t "${TAG}" \
    "${SCRIPT_DIR}"

echo "Done. Image tagged as: ${TAG}"
