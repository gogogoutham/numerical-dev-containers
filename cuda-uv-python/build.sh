#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults (match Dockerfile ARG defaults)
CUDA_VERSION="12.8.1"
CUDA_IMAGE_VARIANT="devel"
UV_VERSION="0.10.2"
UBUNTU_VERSION="24.04"
DRY_RUN=false
PUSH=false
REGISTRY=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --cuda-version)         CUDA_VERSION="$2";        shift 2 ;;
        --cuda-image-variant)   CUDA_IMAGE_VARIANT="$2";  shift 2 ;;
        --uv-version)           UV_VERSION="$2";           shift 2 ;;
        --ubuntu-version)       UBUNTU_VERSION="$2";       shift 2 ;;
        --registry)             REGISTRY="$2";             shift 2 ;;
        --push)                 PUSH=true;                 shift ;;
        --dry-run)              DRY_RUN=true;              shift ;;
        -h|--help)
            echo "Usage: $0 [--cuda-version X] [--cuda-image-variant X] [--uv-version X] [--ubuntu-version X] [--registry X] [--push] [--dry-run]"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [[ "${PUSH}" == true && -z "${REGISTRY}" ]]; then
    echo "Error: --registry is required when using --push" >&2
    exit 1
fi

TAG="cuda-uv-python:cuda${CUDA_VERSION}-${CUDA_IMAGE_VARIANT}-uv${UV_VERSION}-ubuntu${UBUNTU_VERSION}"

DOCKER_CMD="docker build \
    --build-arg CUDA_VERSION=${CUDA_VERSION} \
    --build-arg CUDA_IMAGE_VARIANT=${CUDA_IMAGE_VARIANT} \
    --build-arg UV_VERSION=${UV_VERSION} \
    --build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
    -t ${TAG} \
    ${SCRIPT_DIR}"

if [[ "${DRY_RUN}" == true ]]; then
    echo "${DOCKER_CMD}"
    if [[ "${PUSH}" == true ]]; then
        REMOTE_TAG="${REGISTRY}/${TAG}"
        echo "docker tag ${TAG} ${REMOTE_TAG}"
        echo "docker push ${REMOTE_TAG}"
    fi
else
    echo "Building ${TAG} ..."
    eval "${DOCKER_CMD}"
    echo "Done. Image tagged as: ${TAG}"
    if [[ "${PUSH}" == true ]]; then
        REMOTE_TAG="${REGISTRY}/${TAG}"
        echo "Pushing ${REMOTE_TAG} ..."
        docker tag "${TAG}" "${REMOTE_TAG}"
        docker push "${REMOTE_TAG}"
        echo "Done. Image pushed as: ${REMOTE_TAG}"
    fi
fi
