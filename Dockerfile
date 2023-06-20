# syntax=docker/dockerfile:experimental

# Use a Python base image with the desired version
FROM python:3.9
#FROM continuumio/miniconda3

# Update and install essential packages
RUN apt-get update --fix-missing -y && \
    apt-get install -y \
	build-essential \
#	ncbi-blast+ \
	bc \
	zlib1g-dev \
        wget \
	nano \
        git \
        openssh-client \
        make \
	libx11-dev \
        tree && \
    apt-get clean

# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# clone spotrna2d repo
RUN --mount=type=ssh git clone org-80487435@github.com:OrnaComputationTeam/SPOT-RNA-2D.git /SPOT-RNA-2D && cd SPOT-RNA-2D

# install and setup conda3/mamba
RUN mkdir -p /tmp/conda-build && wget -nv https://repo.anaconda.com/miniconda/Miniconda3-py39_23.3.1-0-Linux-x86_64.sh && bash Miniconda3-py39_23.3.1-0-Linux-x86_64.sh -b -p /miniconda3
RUN cp /miniconda3/bin/conda /miniconda3/bin/conda3
ENV PATH=/miniconda3/bin:$PATH
RUN conda update -y -n base -c defaults conda
RUN conda config --add channels pytorch
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
RUN conda config --add channels r
#RUN conda install -y mamba
RUN conda install -c conda-forge mamba -y

# Set the working directory
WORKDIR /SPOT-RNA-2D

# create conda env
#RUN mamba create -n venv_spotrna_2d python=3.9 && mamba activate venv_spotrna_2d

# install dependencies
RUN mamba install -y -c bioconda blast=2.14.0
RUN mamba install -y -c anaconda pandas numpy pathlib
RUN mamba install -y -c conda-forge tqdm
#RUN mamba install -y -c conda-forge tqdm tensorflow==1.15.0

# install other tools
RUN mamba install -y -c bioconda viennarna infernal easel

# install plmc
RUN git clone https://github.com/debbiemarkslab/plmc && cd plmc && make all-openmp && cd -

# Start the shell
CMD ["/bin/bash"]

