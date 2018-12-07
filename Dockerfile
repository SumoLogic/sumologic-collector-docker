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
    apt-get install -y curl && \
    curl -sL https://s3-us-west-2.amazonaws.com/infra-distributions/riqca/riqca.crt -o /usr/local/share/ca-certificates/riqca.crt && \
    curl -sL https://s3-us-west-2.amazonaws.com/infra-distributions/ecpca/ecpca.crt -o /usr/local/share/ca-certificates/ecpca.crt && \
    update-ca-certificates && \
    curl -sL https://s3-us-west-2.amazonaws.com/infra-distributions/default/linux/go-get-yourself/latest/go-get-yourself.d04e67a -o /usr/local/bin/go-get-yourself && \
    chmod +x /usr/local/bin/go-get-yourself && \
    curl -sL https://s3-us-west-2.amazonaws.com/infra-distributions/aws-instance-metadata-reader/stable/linux/amd64/aws-instance-metadata-reader -o /usr/local/bin/aws-instance-metadata-reader && \
    go-get-yourself get --projectName viq --os linux --version v0.9.1 && \
    mv viq /usr/local/bin/ && \
    go-get-yourself get --projectName crypter-client-go --version v1.0.3 && \
    mv crypter-client-go /usr/local/bin/crypter

COPY ./sfiq/sumo-sources.json /etc/

VOLUME /host

EXPOSE 514/udp
EXPOSE 514

