# syntax=docker/dockerfile:1

# First we build an intermediate image, build 
# dependencies and ssh keys will not persist in the final image
FROM ubuntu as intermediate

# Software versions
ENV EVERYWAN_PROTO_VERSION=v0.1.0
ENV EVERYWAN_CONTROL_PLANE_VERSION=v0.1.1
ENV EVERYWAN_STAMP_LIBRARY_VERSION=v0.1.1
ENV EVERYWAN_CONTROLLER_STATE_VERSION=v0.1.0
ENV EVERYWAN_DATA_PLANE_VERSION=v0.1.0
ENV EVERYWAN_AUTHENTICATION_LIBRARY_VERSION=v0.1.0

# Install tools required for project
RUN apt-get update
RUN apt-get install -y git

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Download public key for bitbucket.org
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts

# Clone the repositories
RUN --mount=type=ssh git clone git@github.com:cscarpitta/pynat.git
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-data-plane.git --branch $EVERYWAN_DATA_PLANE_VERSION
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-proto.git --branch $EVERYWAN_PROTO_VERSION
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-authentication.git --branch $EVERYWAN_AUTHENTICATION_LIBRARY_VERSION
RUN --mount=type=ssh git clone git@github.com:cscarpitta/srv6pm-delay-measurement.git --branch $EVERYWAN_STAMP_LIBRARY_VERSION
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-control-plane.git --branch $EVERYWAN_CONTROL_PLANE_VERSION
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-openssl.git
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-controller-state.git --branch $EVERYWAN_CONTROLLER_STATE_VERSION
RUN --mount=type=ssh git clone git@bitbucket.org:pierventre/srv6-properties-generators.git --branch carmine
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-mininet.git --branch add-ipv4-addrs-to-mgmt-net
RUN --mount=type=ssh git clone git@bitbucket.org:ssalsano/dreamer-topology-parser-and-validator.git --branch carmine
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-applications.git --branch add_ipv6_support

# Build the final image
#FROM python:3.8-slim-bullseye
FROM ubuntu

MAINTAINER Carmine Scarpitta "carmine.scarpitta@uniroma2.it"

# Copy the repository form the intermediate image
COPY --from=intermediate /pynat /code/pynat
COPY --from=intermediate /srv6-sdn-data-plane /code/srv6-sdn-data-plane
COPY --from=intermediate /srv6-sdn-proto /code/srv6-sdn-proto
COPY --from=intermediate /srv6-sdn-authentication /code/srv6-sdn-authentication
COPY --from=intermediate /srv6pm-delay-measurement /code/srv6pm-delay-measurement
COPY --from=intermediate /srv6-sdn-control-plane /code/srv6-sdn-control-plane
COPY --from=intermediate /srv6-sdn-openssl /code/srv6-sdn-openssl
COPY --from=intermediate /srv6-sdn-controller-state /code/srv6-sdn-controller-state
COPY --from=intermediate /srv6-properties-generators /code/srv6-properties-generators
COPY --from=intermediate /srv6-sdn-mininet /code/srv6-sdn-mininet
COPY --from=intermediate /dreamer-topology-parser-and-validator /code/dreamer-topology-parser-and-validator
COPY --from=intermediate /srv6-applications /code/srv6-applications

# Install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y git python3 python3-pip jq libffi-dev libssl-dev graphviz graphviz-dev screen coturn iptables libpcap-dev curl mininet xterm iproute2 iputils-ping
RUN pip3 install protobuf==3.19.1

# Workaround: The patch which introduces the support for End.DT4 and End.DT46
# behaviors has not been accepted yet
# We fix this issue by using our patched version of pyroute2
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

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Add GPG key for frr
RUN curl -s https://deb.frrouting.org/frr/keys.asc | apt-key add -

# frr-stable will be the latest official stable release
RUN echo deb https://deb.frrouting.org/frr focal frr-stable | tee -a /etc/apt/sources.list.d/frr.list

# Update and install FRR
RUN apt update
RUN apt install -y frr frr-pythontools

# Install Mininet
RUN pip3 install mininet

# Install etherws Python library
RUN pip3 install etherws

# Setup pynat
RUN pip3 install six
WORKDIR /code/pynat
RUN python3 setup.py install

# Setup data plane
WORKDIR /code/srv6-sdn-data-plane
RUN python3 setup.py install

# Setup and build protos
WORKDIR /code/srv6-sdn-proto
RUN python3 setup.py install

# Setup authentication utils
WORKDIR /code/srv6-sdn-authentication
RUN python3 setup.py install

# Setup STAMP utils
WORKDIR /code/srv6pm-delay-measurement
RUN python3 setup.py install

# Setup control plane
WORKDIR /code/srv6-sdn-control-plane
RUN python3 setup.py install

# Setup openssl utils
WORKDIR /code/srv6-sdn-openssl
RUN python3 setup.py install

# Setup controller storage utils
WORKDIR /code/srv6-sdn-controller-state
RUN python3 setup.py install

# Setup properties generators
WORKDIR /code/srv6-properties-generators
RUN python3 setup.py install

# Setup topology parser
WORKDIR /code/dreamer-topology-parser-and-validator
RUN python3 setup.py install

# Setup SRv6 applications
WORKDIR /code/srv6-applications
RUN python3 setup.py install

# Set python3 as default choice
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN update-alternatives --install /usr/bin/zebra zebra /lib/frr/zebra 1
RUN update-alternatives --install /usr/bin/ospfd ospfd /lib/frr/ospfd 1
RUN update-alternatives --install /usr/bin/ospf6d ospf6d /lib/frr/ospf6d 1
RUN update-alternatives --install /usr/bin/staticd staticd /lib/frr/staticd 1

# Workaround to set the correct MongoDB Host in the SD-WAN controller starter script
WORKDIR /code/srv6-sdn-mininet/scripts
RUN sed -i 's/python -m srv6_sdn_control_plane.srv6_controller/MONGODB_HOST=mongodb python -m srv6_sdn_control_plane.srv6_controller/g' sdwan_controller.sh 

# Start the EveryEdge
WORKDIR /code/srv6-sdn-mininet
ENTRYPOINT ["python3", "./srv6_mininet_extension.py", "--topo", "topo/topology_h_multisub_ipv6.json"]
