# Sumo Logic Collector Docker Image
# Version 0.1

FROM public.ecr.aws/amazonlinux/amazonlinux:2023
LABEL maintainer="Sumo Logic <docker@sumologic.com>"

RUN dnf upgrade -y && \
    dnf install -y \
    gettext \
    wget && \
    wget -q -O /tmp/collector.rpm https://collectors.sumologic.com/rest/download/rpm/64 && \
    dnf install -y /tmp/collector.rpm && \
    rm /tmp/collector.rpm && \
    dnf clean all && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*

COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash", "/run.sh"]
