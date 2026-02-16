FROM nvidia/cuda:12.8.1-devel-ubuntu24.04

# Install additional OS dependencies
# - CA certs for TLS downloads
# - build tools for native/CUDA extensions (build-essential, ninja, cmake, pkg-config)
# - fetching VCS deps (git) and downloading (curl)
# - tar/xz/zstd because uv-managed Python downloads are archived (safe to include)
# - common Python package build deps (python dev headers via uv-managed Python are handled by uv,
#   but many builds still expect system libs like ffi/ssl)
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    ninja-build \
    cmake \
    pkg-config \
    git \
    curl \
    tar xz-utils zstd \
    libffi-dev \
    libssl-dev
RUN rm -rf /var/lib/apt/lists/*

# Pull in UV binaries from distroless base image and configure
# - UV_TOOL_BIN_DIR ensures that uv installed tools are avaiable
# - UV_MANAGED_PYTHON instructs uv to ignore system python installation
# - UV_CACHE_DIR explicitly names a cache dir that can be shared across container runs via a bind mount
COPY --from=ghcr.io/astral-sh/uv:0.10.2 /uv /uvx /bin/
ENV UV_TOOL_BIN_DIR=/usr/local/bin
ENV UV_MANAGED_PYTHON=1
ENV UV_CACHE_DIR=/cache/uv

# Install Python 3.13 so that it's available for any child virutalenvs
RUN uv python install 3.13

# Sanity checks
RUN nvcc --version && uv run python --version
