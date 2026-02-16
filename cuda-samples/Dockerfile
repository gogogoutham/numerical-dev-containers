FROM nvidia/cuda:13.1.1-devel-ubuntu24.04

# Install some additional packages
RUN apt-get update
RUN apt-get install -y cmake wget unzip

# Download and unzip correct version of cuda-samples repo
RUN wget https://github.com/NVIDIA/cuda-samples/archive/refs/tags/v13.1.zip
RUN unzip v13.1.zip
RUN rm v13.1.zip
RUN mv cuda-samples-13.1 cuda-samples

# Compile cuda samples
RUN mkdir /cuda-samples/build
WORKDIR /cuda-samples/build
RUN cmake ..
RUN make -j$(nproc)
