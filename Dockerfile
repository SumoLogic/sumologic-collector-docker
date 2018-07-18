###############################################################################

FROM ubuntu:14.04 as builder

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update --quiet && \
 apt-get upgrade --quiet --force-yes -y && \
 apt-get install --quiet --force-yes -y wget && \
 wget -q -O /tmp/collector.deb https://collectors.sumologic.com/rest/download/deb/64 && \
 dpkg -i /tmp/collector.deb

###############################################################################

FROM alpine

RUN apk add --no-cache bash
RUN apk --no-cache add ca-certificates wget &&\
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub &&\
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-2.27-r0.apk &&\
    apk add glibc-2.27-r0.apk &&\
    rm *.apk

COPY --from=builder /opt/SumoCollector/ /opt/SumoCollector/
COPY run.sh /run.sh 
COPY docker-sources/sumo-sources.json /etc/sumo-sources.json

ENTRYPOINT ["/bin/bash", "/run.sh"]
