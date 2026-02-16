# Numerical Programming Dev Containers

This repo contains build recipes for Docker containers that serve as a starting point for numerical programming projects. Each container family lives in its own subdirectory with a `Dockerfile` and a parameterized `build.sh` script. A top-level orchestration script (`build-all.sh`) drives builds across the full matrix defined in `builds.yaml`.

## Container families

### cuda-samples

NVIDIA CUDA development image with the [cuda-samples](https://github.com/NVIDIA/cuda-samples) repository downloaded and compiled. Useful for validating that a GPU setup is working correctly.

Build arguments:
- `CUDA_VERSION` — CUDA toolkit version (e.g. `13.1.1`)
- `CUDA_SAMPLES_VERSION` — samples release tag (e.g. `13.1`); defaults to `major.minor` of `CUDA_VERSION`
- `UBUNTU_VERSION` — base Ubuntu version (default `24.04`)

### cuda-uv-python

NVIDIA CUDA development image with [uv](https://github.com/astral-sh/uv) pre-installed for Python package management. Comes in the same flavor variants (e.g. `devel`, `cudnn-devel`, etc.) as the [nvidia/cuda](https://hub.docker.com/r/nvidia/cuda#overview-of-images) images upon which these are based. A handful of OS dependencies commonly used by Python packages come preinstalled. A managed Python is installed via `uv` at build time and verified alongside `nvcc`.

Build arguments:
- `CUDA_VERSION` — CUDA toolkit version (e.g. `12.8.1`)
- `CUDA_IMAGE_VARIANT` — base image variant (`devel`, `cudnn-devel`, or another choice from [nvidia/cuda](https://hub.docker.com/r/nvidia/cuda#overview-of-images))
- `UV_VERSION` — uv release version (e.g. `0.10.2`)
- `UBUNTU_VERSION` — base Ubuntu version (default `24.04`)

## Prerequisites

- **Docker** — any recent version with BuildKit support
- **[yq](https://github.com/mikefarah/yq)** — used by `build-all.sh` to parse `builds.yaml`

## Usage

### Build all images locally

```bash
./build-all.sh
```

### Dry run (print docker commands without executing)

```bash
./build-all.sh --dry-run
```

### Build a single image

```bash
./cuda-uv-python/build.sh --cuda-version 12.8.1 --cuda-image-variant devel --uv-version 0.10.2
```

### Build and push to a container registry

```bash
./build-all.sh --push --registry ghcr.io/<username>
```

This builds every image in `builds.yaml`, then tags and pushes each one to the specified registry. The resulting image references follow the pattern:

```
ghcr.io/<username>/cuda-uv-python:cuda12.8.1-devel-uv0.10.2-ubuntu24.04
```

Pushing requires prior authentication:

```bash
echo "<PAT>" | docker login ghcr.io -u <username> --password-stdin
```

The token needs the `write:packages` scope. You can also pass `--push` and `--registry` to individual `build.sh` scripts.

### Use a custom build matrix

```bash
./build-all.sh /path/to/custom-builds.yaml
```

## GitHub Actions

The workflow at `.github/workflows/build-and-push.yaml` builds and pushes all images on every push to `main` and on manual dispatch (`workflow_dispatch`). It:

1. Checks out the repository
2. Installs `yq`
3. Authenticates to ghcr.io using the automatic `GITHUB_TOKEN`
4. Runs `./build-all.sh --push --registry ghcr.io/<owner>`

No secrets or PATs need to be configured — the workflow uses `GITHUB_TOKEN` with `packages: write` permission, which GitHub provisions automatically.
