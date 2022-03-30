# Sumo Logic Collector Docker Image
# Version 0.1

FROM ubuntu:20.04
LABEL org.opencontainers.image.authors="Sumo Logic <docker@sumologic.com>"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --quiet && \
 apt-get install -y --no-install-recommends apt-utils && \
 apt-get upgrade --quiet --allow-downgrades --allow-remove-essential --allow-change-held-packages -y && \
 apt-get install --quiet --allow-downgrades --allow-remove-essential --allow-change-held-packages -y wget && \
 wget -q -O /tmp/collector.deb https://collectors.sumologic.com/rest/download/deb/64 && \
 dpkg -i /tmp/collector.deb && \
 rm /tmp/collector.deb && \
 apt-get clean --quiet && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash", "/run.sh"]
