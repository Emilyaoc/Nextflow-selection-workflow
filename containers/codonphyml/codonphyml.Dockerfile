# Use separate image for compiling software ( builder image )
FROM ubuntu:22.04 AS builder

# Install packages necessary for compiling
# Atlas library headers needed for BLAS option could not be found. Sticking with OpenMP.
RUN apt-get update && apt-get -y install \
    automake \
    build-essential \
    libomp-dev \
    libyaml-dev \
    unzip \
    wget

# Fetch source from Sourceforge
WORKDIR /opt
RUN wget http://downloads.sourceforge.net/project/codonphyml/codonPhyML_dev_1.00_201407.24.zip && \
    unzip codonPhyML_dev_1.00_201407.24.zip

# Compile using the same options as make_phyml_omp and modify ./configure to use --with-yaml
RUN cd codonPHYML_dev/ && \
    aclocal && \
    autoheader && \
    autoconf -f && \
    automake -f --add-missing && \
    ./configure --enable-omp --with-yaml && \
    make clean && \
    make

# Create image for running software
FROM ubuntu:22.04

# Install packages for running software
# build-essential contains the linked openmp library for some reason.
RUN apt-get update && apt-get -y install \
    build-essential \
    libomp-dev \
    libyaml-dev

# Copy executable from builder image
COPY --from=builder /opt/codonPHYML_dev/src/codonphyml /usr/local/bin/

# Add metadata
LABEL description="A container for CodonPhyML" \
    container_author="Mahesh Binzer-Panchal" \
    version="1.0" \
    URL="https://sourceforge.net/projects/codonphyml/"

# Add default container command
CMD [ "codonphyml" ]
