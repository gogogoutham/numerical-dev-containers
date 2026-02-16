#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults (match Dockerfile ARG defaults)
CUDA_VERSION="12.8.1"
CUDA_IMAGE_VARIANT="devel"
UV_VERSION="0.10.2"
UBUNTU_VERSION="24.04"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --cuda-version)    CUDA_VERSION="$2";       shift 2 ;;
        --cudnn)           CUDA_IMAGE_VARIANT="cudnn-devel"; shift ;;
        --uv-version)      UV_VERSION="$2";          shift 2 ;;
        --ubuntu-version)  UBUNTU_VERSION="$2";      shift 2 ;;
        -h|--help)
            echo "Usage: $0 [--cuda-version X] [--cudnn] [--uv-version X] [--ubuntu-version X]"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

TAG="cuda-uv-python:cuda${CUDA_VERSION}-${CUDA_IMAGE_VARIANT}-uv${UV_VERSION}-ubuntu${UBUNTU_VERSION}"

echo "Building ${TAG} ..."

docker build \
    --build-arg CUDA_VERSION="${CUDA_VERSION}" \
    --build-arg CUDA_IMAGE_VARIANT="${CUDA_IMAGE_VARIANT}" \
    --build-arg UV_VERSION="${UV_VERSION}" \
    --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" \
    -t "${TAG}" \
    "${SCRIPT_DIR}"

echo "Done. Image tagged as: ${TAG}"
