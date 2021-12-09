# syntax=docker/dockerfile:1

FROM ubuntu

MAINTAINER Carmine Scarpitta "carmine.scarpitta@uniroma2.it"

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    net-tools \
    tcpdump \
    iputils-ping \
    traceroute \
    iputils-tracepath \
    nmap \
    dnsutils \
    wireless-tools \
    iproute2 \
    iperf3

CMD ["bash", "-c", "trap : TERM INT; sleep infinity & wait"]
