FROM continuumio/miniconda3

WORKDIR /home

# Adapted and simplified from eichler lab dockerfile
# Default build libraries
RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        ca-certificates \
        libbz2-dev \
        libcurl4-openssl-dev \
        liblzma-dev \
        libncurses5-dev \
        autoconf \
        automake \
        bzip2 \
        gcc \
        g++ \
        git \
        make \
        wget \
        xz-utils \
        zlib1g-dev

COPY envs/svbyeye.yaml /
RUN conda env create -f /svbyeye.yaml && conda clean -a
RUN echo "conda activate r_env" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

RUN Rscript -e "library(remotes); remotes::install_github('daewoooo/SVbyEye', repos='http://cran.us.r-project.org')"

ENV PATH=/opt/conda/envs/r_env/bin:$PATH
