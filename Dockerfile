# Sumo Logic Collector Docker Image
# Version 0.1

FROM ubuntu:14.04
MAINTAINER Sumo Logic <docker@sumologic.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --quiet && \
 apt-get upgrade --quiet --force-yes -y && \
 apt-get install --quiet --force-yes -y wget && \
 wget -q -O /tmp/collector.deb https://collectors.sumologic.com/rest/download/deb/64 && \
 dpkg -i /tmp/collector.deb && \
 rm /tmp/collector.deb && \
 apt-get remove --quiet --force-yes -y wget && \
 apt-get clean --quiet && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY run.sh run.sh 
ENTRYPOINT ["/bin/bash", "run.sh"]

# SFIQ customization
RUN apt-get update && \
    apt-get install -y python curl && \
    curl -ksL https://bootstrap.pypa.io/get-pip.py | python

# internal deps, we do NOT want cache for them
# let's bust the cache by referencing an ARG that's supposed to be different for each build
ARG BUILD_NUMBER
COPY ./sfiq/requirement_internal.txt sfiq/requirement_internal_${BUILD_NUMBER}.txt
RUN pip install -r sfiq/requirement_internal_${BUILD_NUMBER}.txt

COPY ./sfiq/get_key.py sfiq/
COPY ./sfiq/sumo-sources.json /etc/

VOLUME /logs

EXPOSE 514/udp
EXPOSE 514

