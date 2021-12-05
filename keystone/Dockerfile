FROM ubuntu:16.04
LABEL mainteiner="Francesco Lombardo <franclombardo@gmail.com>"
EXPOSE 5000
EXPOSE 35357
RUN apt-get update && apt-get install -y keystone apache2 libapache2-mod-wsgi
ARG KEYSTONE_DB_PASSWORD
ARG KEYSTONE_DB_HOST
ARG HTTP
ARG KEYSTONE_ADMIN_PASSWORD
ENV KEYSTONE_DB_PASSWORD $KEYSTONE_DB_PASSWORD
ENV KEYSTONE_DB_HOST $KEYSTONE_DB_HOST
ENV HTTP $HTTP
ENV KEYSTONE_ADMIN_PASSWORD $KEYSTONE_ADMIN_PASSWORD
COPY ./keystone.conf /etc/keystone/keystone.conf
COPY .env /.env
COPY bootstrap.sh /bootstrap.sh
WORKDIR /root
CMD sh -x /bootstrap.sh
