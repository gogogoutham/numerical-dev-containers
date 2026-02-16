ARG CUDA_VERSION=12.8.1
ARG CUDA_IMAGE_VARIANT=devel
ARG UV_VERSION=0.10.2
ARG UBUNTU_VERSION=24.04
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM nvidia/cuda:${CUDA_VERSION}-${CUDA_IMAGE_VARIANT}-ubuntu${UBUNTU_VERSION}

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
COPY --from=uv /uv /uvx /bin/
ENV UV_TOOL_BIN_DIR=/usr/local/bin
ENV UV_MANAGED_PYTHON=1
ENV UV_CACHE_DIR=/cache/uv

# Install a version Python to verify that everything works
RUN uv python install

# Sanity checks
RUN nvcc --version && uv run python --version
