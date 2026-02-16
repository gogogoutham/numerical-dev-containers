#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
PUSH=false
REGISTRY=""
CONFIG_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)   DRY_RUN=true;    shift ;;
        --push)      PUSH=true;       shift ;;
        --registry)  REGISTRY="$2";   shift 2 ;;
        *)           CONFIG_FILE="$1"; shift ;;
    esac
done

CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/builds.yaml}"

if ! command -v yq &>/dev/null; then
    echo "Error: yq is required but not found on PATH." >&2
    echo "Install it from https://github.com/mikefarah/yq" >&2
    exit 1
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Error: config file not found: ${CONFIG_FILE}" >&2
    exit 1
fi

if [[ "${PUSH}" == true && -z "${REGISTRY}" ]]; then
    echo "Error: --registry is required when using --push" >&2
    exit 1
fi

NUM_BUILDS=$(yq '.builds | length' "${CONFIG_FILE}")
BUILT_TAGS=()

for ((i = 0; i < NUM_BUILDS; i++)); do
    IMAGE=$(yq ".builds[${i}].image" "${CONFIG_FILE}")
    BUILD_SCRIPT="${SCRIPT_DIR}/${IMAGE}/build.sh"

    if [[ ! -x "${BUILD_SCRIPT}" ]]; then
        echo "Error: build script not found or not executable: ${BUILD_SCRIPT}" >&2
        exit 1
    fi

    # Collect all keys except "image" as --key value flags
    FLAGS=()
    while IFS= read -r key; do
        value=$(yq ".builds[${i}].${key}" "${CONFIG_FILE}")
        FLAGS+=("--${key}" "${value}")
    done < <(yq ".builds[${i}] | del(.image) | keys | .[]" "${CONFIG_FILE}")

    if [[ "${DRY_RUN}" == true ]]; then
        FLAGS+=("--dry-run")
    fi

    if [[ "${PUSH}" == true ]]; then
        FLAGS+=("--push")
    fi

    if [[ -n "${REGISTRY}" ]]; then
        FLAGS+=("--registry" "${REGISTRY}")
    fi

    echo "=== Build $((i + 1))/${NUM_BUILDS}: ${IMAGE} ${FLAGS[*]:-} ==="
    "${BUILD_SCRIPT}" "${FLAGS[@]}"

    BUILT_TAGS+=("${IMAGE} ${FLAGS[*]:-}")
    echo ""
done

echo "=== All ${NUM_BUILDS} builds completed ==="
for ((i = 0; i < ${#BUILT_TAGS[@]}; i++)); do
    echo "  $((i + 1)). ${BUILT_TAGS[i]}"
done
