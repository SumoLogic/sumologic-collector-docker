# Sumo Logic Collector Docker Image
# Version 0.1

FROM ubuntu:14.04
MAINTAINER Sumo Logic <docker@sumologic.com>

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get update --quiet && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade --quiet --force-yes -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install --quiet --force-yes -y wget && \
  wget -q -O /tmp/collector.deb https://collectors.sumologic.com/rest/download/deb/64 && \
  dpkg -i /tmp/collector.deb && \
  rm /tmp/collector.deb && \
  DEBIAN_FRONTEND=noninteractive apt-get remove --quiet --force-yes -y wget && \
  DEBIAN_FRONTEND=noninteractive apt-get clean --quiet && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV COLLECTOR_MEM 128
ENV WRAPPER_DEBUG FALSE
ENV LOG_TO_STDOUT FALSE

COPY run.sh run.sh

CMD ["/bin/bash", "run.sh"]
