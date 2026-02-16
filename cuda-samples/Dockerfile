ARG CUDA_VERSION=13.1.1
ARG UBUNTU_VERSION=24.04
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}

# Install some additional packages
RUN apt-get update
RUN apt-get install -y cmake wget unzip

# Download and unzip correct version of cuda-samples repo
ARG CUDA_SAMPLES_VERSION=13.1
RUN wget https://github.com/NVIDIA/cuda-samples/archive/refs/tags/v${CUDA_SAMPLES_VERSION}.zip
RUN unzip v${CUDA_SAMPLES_VERSION}.zip
RUN rm v${CUDA_SAMPLES_VERSION}.zip
RUN mv cuda-samples-${CUDA_SAMPLES_VERSION} cuda-samples

# Compile cuda samples
RUN mkdir /cuda-samples/build
WORKDIR /cuda-samples/build
RUN cmake ..
RUN make -j$(nproc)
