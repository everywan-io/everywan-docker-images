# syntax=docker/dockerfile:1

# Multi-stage build

# First we build an intermediate image, build 
# dependencies and ssh keys will not persist in the final image
FROM ubuntu as intermediate

# Software versions
ENV EVERYEDGEOS_VERSION=v0.5.6

# Install tools required for project
RUN apt-get update
RUN apt-get install -y git

# Add credentials on build
# ARG SSH_PRIVATE_KEY
# RUN mkdir /root/.ssh/
# RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
# RUN chmod 600 /root/.ssh/id_rsa

# Make sure bitbucket and github domains are accepted
# RUN touch /root/.ssh/known_hosts
# RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
# RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Download public key for bitbucket.org
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts

# Clone the repositories
RUN git clone https://github.com/cscarpitta/everyedgeos.git --branch ${EVERYEDGEOS_VERSION} ${REPOS_FOLDER}/everyedgeos || { echo 'Failed' ; exit 1; }
WORKDIR ${REPOS_FOLDER}/everyedgeos
RUN git submodule update --init || { echo 'Failed' ; exit 1; }
RUN git clone https://github.com/cscarpitta/etherws.git ${REPOS_FOLDER}/etherws || { echo 'Failed' ; exit 1; }

# Build the final image
#FROM python:3.8-slim-bullseye
FROM ubuntu:focal

MAINTAINER Carmine Scarpitta "carmine.scarpitta@uniroma2.it"

# Copy the repository form the intermediate image
COPY --from=intermediate /everyedgeos /code/everyedgeos
COPY --from=intermediate /etherws /code/etherws

# Install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y graphviz graphviz-dev python3 python3-pip iputils-ping ethtool
RUN pip3 install protobuf==3.19.1

# Workaround: We install a patched version of pyroute2 that solves an issue related to fdb
# RUN apt-get install -y git build-essential
# RUN pip3 install twine
# RUN git clone https://github.com/cscarpitta/pyroute2.git --branch fix-fdb-replace-issue /code/pyroute2 || { echo 'Failed' ; exit 1; }
# WORKDIR /code/pyroute2 || { echo 'Failed' ; exit 1; }
# RUN make dist python=python3 || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2.core-* || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2.ethtool-* || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2.ipdb-* || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2.ipset-* || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2.minimal-* || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2.ndb-* || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2.nftables-* || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2.nslink-* || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2.protocols-* || { echo 'Failed' ; exit 1; }
# RUN pip3 install dist/pyroute2-* || { echo 'Failed' ; exit 1; }

# Setup pynat
RUN pip3 install six
WORKDIR /code/everyedgeos/src/pynat
RUN python3 setup.py install

# Setup control plane
WORKDIR /code/everyedgeos/src/srv6-sdn-control-plane
RUN python3 setup.py install

# Setup and build protos
WORKDIR /code/everyedgeos/src/srv6-sdn-proto
RUN python3 setup.py install

# Setup openssl utils
WORKDIR /code/everyedgeos/src/srv6-sdn-openssl
RUN python3 setup.py install

# Setup database utils
WORKDIR /code/everyedgeos/src/srv6-sdn-controller-state
RUN python3 setup.py install

# Setup authentication utils
WORKDIR /code/everyedgeos/src/srv6-sdn-authentication
RUN python3 setup.py install

# Setup STAMP utils
WORKDIR /code/everyedgeos/src/srv6pm-delay-measurement
RUN python3 setup.py install

# Setup properties generators
WORKDIR /code/everyedgeos/src/srv6-properties-generators
RUN python3 setup.py install

# Workaround to force the installation of a custom version of rollbackcontext
# patched to work with python3
RUN apt-get update
RUN apt-get install -y git
RUN pip install -e git+https://github.com/cscarpitta/rollbackcontext.git@porting-to-python3#egg=rollbackcontext

# Setup etherws
WORKDIR /code/etherws
RUN python3 setup.py install

# Expose Northbound APIs
EXPOSE 50061
EXPOSE 54321

# Run the controller
WORKDIR /code/everyedgeos/src/srv6-sdn-control-plane
COPY config.ini /configs/config.ini
#CMD ["python", "-m", "srv6_sdn_control_plane.srv6_controller"]
COPY ./entrypoint.sh /entrypoint.sh
CMD ["bash", "/entrypoint.sh"]
#, "--config-file", "gRPC"]

#ENV FLASK_APP=app.py
#ENV FLASK_RUN_HOST=0.0.0.0
#RUN apk add --no-cache gcc musl-dev linux-headers
#COPY requirements.txt requirements.txt
#RUN pip install -r requirements.txt
#EXPOSE 5000
#COPY . .
#CMD ["flask", "run"]
