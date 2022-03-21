# syntax=docker/dockerfile:1

# Multi-stage build

# First we build an intermediate image, build 
# dependencies and ssh keys will not persist in the final image
FROM ubuntu as intermediate

# Software versions
ENV EVERYEDGE_VERSION=v0.4.1

# Install tools required for project
RUN apt-get update
RUN apt-get install -y git

# Folder where to download the repositories
${REPOS_FOLDER}=/tmp

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
RUN git clone https://github.com/cscarpitta/everyedge.git --branch ${EVERYEDGE_VERSION} ${REPOS_FOLDER}/everyedge || { echo 'Failed' ; exit 1; }
WORKDIR ${REPOS_FOLDER}/everyedge
RUN git submodule update --init || { echo 'Failed' ; exit 1; }

# Build the final image
#FROM python:3.8-slim-bullseye
FROM ubuntu

MAINTAINER Carmine Scarpitta "carmine.scarpitta@uniroma2.it"

# Copy the repository form the intermediate image
COPY --from=intermediate ${REPOS_FOLDER}/everyedge /code/everyedge

# Install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y python3 python3-pip jq
RUN pip3 install protobuf==3.19.1

# Workaround: The patch which introduces the support for End.DT4 and End.DT46
# behaviors has not been accepted yet
# We fix this issue by using our patched version of pyroute2
RUN apt-get install -y git
RUN pip3 install twine
RUN git clone https://github.com/cscarpitta/pyroute2.git --branch srv6_end_dt4 /tmp/pyroute2
WORKDIR /tmp/pyroute2
RUN make dist python=python3
RUN pip3 install dist/pyroute2.core-*
RUN pip3 install dist/pyroute2.ethtool-*
RUN pip3 install dist/pyroute2.ipdb-*
RUN pip3 install dist/pyroute2.ipset-*
RUN pip3 install dist/pyroute2.minimal-*
RUN pip3 install dist/pyroute2.ndb-*
RUN pip3 install dist/pyroute2.nftables-*
RUN pip3 install dist/pyroute2.nslink-*
RUN pip3 install dist/pyroute2.protocols-*
RUN pip3 install dist/pyroute2-*

# Setup pynat
RUN pip3 install six
WORKDIR /code/everyedge/src/pynat
RUN python3 setup.py install

# Setup data plane
WORKDIR /code/everyedge/src/srv6-sdn-data-plane
RUN python3 setup.py install

# Setup and build protos
WORKDIR /code/everyedge/src/srv6-sdn-proto
RUN python3 setup.py install

# Setup authentication utils
WORKDIR /code/everyedge/src/srv6-sdn-authentication
RUN python3 setup.py install

# Setup STAMP utils
WORKDIR /code/everyedge/src/srv6pm-delay-measurement
RUN python3 setup.py install

# Expose Northbound APIs
EXPOSE 12345

# Generate the device configuration
WORKDIR /code/srv6-sdn-data-plane
ENV CONFIG '{"id":"","features":[{"name":"gRPC","port":12345},{"name":"SSH","port":22}]}'

# Export the configuration
RUN jq -n ${CONFIG} > /tmp/config-everyedge.json

VOLUME /usr/share/everyedge

# Setup iptables and libpcap
RUN apt-get install -y iptables libpcap-dev
RUN update-alternatives --set ip6tables /usr/sbin/ip6tables-nft

# Run the EveryEdge device
WORKDIR /code/srv6-sdn-data-plane
COPY config.ini /configs/config.ini
COPY device-info.json /configs/device-info.json
#CMD ["python", "-m", "srv6_sdn_control_plane.srv6_controller"]
#CMD ["python3", "-m", "srv6_sdn_data_plane.ew_edge_device", "--device-config-file", "/tmp/config-everyedge.json", "--nat-discovery-server-ip", "0.0.0.0", "--nat-discovery-client-ip", "0.0.0.0", "--pymerang-server-ip", "0.0.0.0", "--pymerang-server-port", "50061", "--token-file", "/usr/share/everyedge/token"]
CMD ["python3", "-m", "srv6_sdn_data_plane.ew_edge_device", "-c", "/etc/everyedge/config.ini"]
#"-c", "sample_config.ini"]

#ENV FLASK_APP=app.py
#ENV FLASK_RUN_HOST=0.0.0.0
#RUN apk add --no-cache gcc musl-dev linux-headers
#COPY requirements.txt requirements.txt
#RUN pip install -r requirements.txt
#EXPOSE 5000
#COPY . .
#CMD ["flask", "run"]

# TODO: add etherws