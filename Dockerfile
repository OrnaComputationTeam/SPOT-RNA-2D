# syntax=docker/dockerfile:experimental
# usage: export DOCKER_BUILDKIT=1; docker build --ssh default -t spotrna2d -f Dockerfile .

# Use our base Dockerfile located in CodeCommit
FROM 680677605106.dkr.ecr.us-east-1.amazonaws.com/ornatx-cicd-docker-image-mamba:main

RUN  apt-get -yq update && \
     apt-get -yqq install ssh

# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

COPY spec-file.txt /spec-file.txt

# install packages
RUN mamba install --name base --file /spec-file.txt && mamba clean -a
#RUN mamba install -y -c conda-forge tensorflow==1.15.0

# clone spotrna2d repo
RUN --mount=type=ssh git clone org-80487435@github.com:OrnaComputationTeam/SPOT-RNA-2D.git /SPOT-RNA-2D && cd SPOT-RNA-2D

# Set the working directory
WORKDIR /SPOT-RNA-2D

# Start the shell
CMD ["/bin/bash"]
