# syntax=docker/dockerfile:1

# Multi-stage build

# First we build an intermediate image, build 
# dependencies and ssh keys will not persist in the final image
FROM ubuntu as intermediate

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
RUN --mount=type=ssh git clone git@github.com:cscarpitta/pynat.git
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-control-plane.git --branch experimental/dockerize-controller
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-proto.git --branch experimental/dockerize-controller
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-openssl.git
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-controller-state.git --branch experimental-dockerize-controller
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-authentication.git --branch experimental/dockerize-everyedge
RUN --mount=type=ssh git clone git@github.com:cscarpitta/srv6pm-delay-measurement.git --branch feature/align-to-mgmt-plane
RUN --mount=type=ssh git clone git@bitbucket.org:pierventre/srv6-properties-generators.git --branch carmine

# Build the final image
#FROM python:3.8-slim-bullseye
FROM ubuntu

MAINTAINER Carmine Scarpitta "carmine.scarpitta@uniroma2.it"

# Copy the repository form the intermediate image
COPY --from=intermediate /pynat /code/pynat
COPY --from=intermediate /srv6-sdn-control-plane /code/srv6-sdn-control-plane
COPY --from=intermediate /srv6-sdn-proto /code/srv6-sdn-proto
COPY --from=intermediate /srv6-sdn-openssl /code/srv6-sdn-openssl
COPY --from=intermediate /srv6-sdn-controller-state /code/srv6-sdn-controller-state
COPY --from=intermediate /srv6-sdn-authentication /code/srv6-sdn-authentication
COPY --from=intermediate /srv6pm-delay-measurement /code/srv6pm-delay-measurement
COPY --from=intermediate /srv6-properties-generators /code/srv6-properties-generators

# Install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y graphviz graphviz-dev python3 python3-pip
RUN pip3 install protobuf==3.19.1

# Setup pynat
RUN pip3 install six
WORKDIR /code/pynat
RUN python3 setup.py install

# Setup control plane
WORKDIR /code/srv6-sdn-control-plane
RUN python3 setup.py install

# Setup and build protos
WORKDIR /code/srv6-sdn-proto
RUN python3 setup.py install

# Setup openssl utils
WORKDIR /code/srv6-sdn-openssl
RUN python3 setup.py install

# Setup database utils
WORKDIR /code/srv6-sdn-controller-state
RUN python3 setup.py install

# Setup authentication utils
WORKDIR /code/srv6-sdn-authentication
RUN python3 setup.py install

# Setup STAMP utils
WORKDIR /code/srv6pm-delay-measurement
RUN python3 setup.py install

# Setup properties generators
WORKDIR /code/srv6-properties-generators
RUN python3 setup.py install

# Expose Northbound APIs
EXPOSE 50061
EXPOSE 54321

# Run the controller
WORKDIR /code/srv6-sdn-control-plane
COPY config.ini /configs/config.ini
#CMD ["python", "-m", "srv6_sdn_control_plane.srv6_controller"]
CMD ["python3", "-m", "srv6_sdn_control_plane.srv6_controller", "-c", "/configs/config.ini"]
#, "--config-file", "gRPC"]

#ENV FLASK_APP=app.py
#ENV FLASK_RUN_HOST=0.0.0.0
#RUN apk add --no-cache gcc musl-dev linux-headers
#COPY requirements.txt requirements.txt
#RUN pip install -r requirements.txt
#EXPOSE 5000
#COPY . .
#CMD ["flask", "run"]
