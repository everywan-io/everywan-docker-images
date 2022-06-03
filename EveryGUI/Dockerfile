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
# RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone the repositories
RUN --mount=type=ssh git clone git@github.com:everywan-io/EveryGUI.git --branch multitenancy-support

# Build the final image
#FROM python:3.8-slim-bullseye
FROM ubuntu as build

MAINTAINER Carmine Scarpitta "carmine.scarpitta@uniroma2.it"

# Copy the repository form the intermediate image
COPY --from=intermediate /EveryGUI /code/EveryGUI

# Install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nodejs npm curl
#curl
# RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
#     && source ~/.bashrc \
#     && nvm install 16.10 \
#     && nvm use 16.10 \
#     && npm install -g @angular/cli
RUN npm install -g n
RUN n 12.20
RUN n use 12.20
RUN npm install -g @angular/cli@12.2.11

# Start EveryGUI
WORKDIR /code/EveryGUI
RUN npm install
RUN ng build everywan-backoffice -c production
#CMD ["ng", "serve", "-c", "local"]

# Use official nginx image as the base image
FROM nginx:latest

# Copy the NGINX configuration
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy the build output to replace the default nginx contents.
COPY --from=build /code/EveryGUI/dist/everywan-backoffice /usr/share/nginx/html

# Expose port 80
EXPOSE 80

#ENV FLASK_APP=app.py
#ENV FLASK_RUN_HOST=0.0.0.0
#RUN apk add --no-cache gcc musl-dev linux-headers
#COPY requirements.txt requirements.txt
#RUN pip install -r requirements.txt
#EXPOSE 5000
#COPY . .
#CMD ["flask", "run"]
