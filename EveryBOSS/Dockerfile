# syntax=docker/dockerfile:1

# Multi-stage build

# First we build an intermediate image, build 
# dependencies and ssh keys will not persist in the final image
FROM ubuntu as intermediate

# Software versions
ENV EVERYWAN_PROTO_VERSION=v0.1.0
ENV EVERYWAN_CONTROL_PLANE_VERSION=v0.3.4
ENV EVERYWAN_STAMP_LIBRARY_VERSION=v0.3.3
# ENV EVERYWAN_CONTROLLER_STATE_VERSION=v0.1.0
# ENV EVERYWAN_DATA_PLANE_VERSION=v0.1.0
# ENV EVERYWAN_AUTHENTICATION_LIBRARY_VERSION=v0.1.0

# Install tools required for project
RUN apt-get update
RUN apt-get install -y git

# Add credentials on build
#ARG SSH_PRIVATE_KEY
#RUN mkdir /root/.ssh/
#RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
#RUN chmod 600 /root/.ssh/id_rsa

# Make sure bitbucket and github domains are accepted
#RUN touch /root/.ssh/known_hosts
#RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Download public key for bitbucket.org
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts

# Clone the repositories
RUN --mount=type=ssh git clone git@github.com:everywan-io/EveryBOSS.git --branch multitenancy-support
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-control-plane.git --branch $EVERYWAN_CONTROL_PLANE_VERSION
RUN --mount=type=ssh git clone git@github.com:everywan-io/srv6-sdn-proto.git --branch $EVERYWAN_PROTO_VERSION
RUN --mount=type=ssh git clone git@github.com:cscarpitta/srv6pm-delay-measurement.git --branch $EVERYWAN_STAMP_LIBRARY_VERSION
RUN --mount=type=ssh git clone git@bitbucket.org:pierventre/srv6-properties-generators.git --branch carmine

# Build the final image
#FROM python:3.8-slim-bullseye
FROM ubuntu

MAINTAINER Carmine Scarpitta "carmine.scarpitta@uniroma2.it"

# Copy the repository form the intermediate image
COPY --from=intermediate /EveryBOSS /code/EveryBOSS
COPY --from=intermediate /srv6-sdn-control-plane /code/srv6-sdn-control-plane
COPY --from=intermediate /srv6-sdn-proto /code/srv6-sdn-proto
COPY --from=intermediate /srv6pm-delay-measurement /code/srv6pm-delay-measurement
COPY --from=intermediate /srv6-properties-generators /code/srv6-properties-generators

# Install dependencies
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install -y python3.6 pipenv graphviz graphviz-dev
RUN pip3 install protobuf==3.19.1

# Setup control plane
WORKDIR /code/srv6-sdn-control-plane
RUN python3 setup.py install

# Setup and build protos
WORKDIR /code/srv6-sdn-proto
RUN python3 setup.py install

# Setup STAMP utils
WORKDIR /code/srv6pm-delay-measurement
RUN python3 setup.py install

# Setup properties generators
WORKDIR /code/srv6-properties-generators
RUN python3 setup.py install

# Setup EveryBOSS
WORKDIR /code/EveryBOSS
RUN pipenv --python python3.6 install --system --deploy --ignore-pipfile
WORKDIR /code/EveryBOSS

CMD ["bash", "run_dev_env.sh"]
#, "--config-file", "gRPC"]

#ENV FLASK_APP=app.py
#ENV FLASK_RUN_HOST=0.0.0.0
#RUN apk add --no-cache gcc musl-dev linux-headers
#COPY requirements.txt requirements.txt
#RUN pip install -r requirements.txt
#EXPOSE 5000
#COPY . .
#CMD ["flask", "run"]
