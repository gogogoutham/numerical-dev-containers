#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
CONFIG_FILE=""

for arg in "$@"; do
    case "${arg}" in
        --dry-run) DRY_RUN=true ;;
        *)         CONFIG_FILE="${arg}" ;;
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

    echo "=== Build $((i + 1))/${NUM_BUILDS}: ${IMAGE} ${FLAGS[*]:-} ==="
    "${BUILD_SCRIPT}" "${FLAGS[@]}"

    BUILT_TAGS+=("${IMAGE} ${FLAGS[*]:-}")
    echo ""
done

echo "=== All ${NUM_BUILDS} builds completed ==="
for ((i = 0; i < ${#BUILT_TAGS[@]}; i++)); do
    echo "  $((i + 1)). ${BUILT_TAGS[i]}"
done
