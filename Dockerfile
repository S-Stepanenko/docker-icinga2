FROM alpine:latest

LABEL maintainer="pluhin@gmail.com"

ENV ICINGA_VERSION="2.11.3"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk update --no-cache \
    && apk add --no-cache \
         icinga2 \
         bash \
    && rm -rf \
          /tmp/* \
          /var/cache/apk/* 
RUN icinga2 api setup \
    && icinga2 feature enable \
      ido-pgsql \
      checker \
      command \
      notification 
    #&& rm -rf /var/lib/icinga2/certs
#COPY files/Icinga2/ /var/lib/icinga2/
#RUN chown -R icinga:icinga /var/lib/icinga2/certs

EXPOSE 5665