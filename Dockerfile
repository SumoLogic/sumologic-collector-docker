# Sumo Logic Collector Docker Image
# Version 0.1

FROM alpine:3.14
LABEL maintainer="Sumo Logic <docker@sumologic.com>"
ENV DEBIAN_FRONTEND noninteractive
RUN apk update && apk add wget
 wget -q -O /tmp/collector.deb https://collectors.sumologic.com/rest/download/deb/64 && \
 dpkg -i /tmp/collector.deb && \
 rm /tmp/collector.deb && \
 apt-get clean --quiet && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash", "/run.sh"]
