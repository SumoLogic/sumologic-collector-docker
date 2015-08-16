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

ADD sumo-sources.json /etc/sumo-sources.json

WORKDIR "/opt/SumoCollector"

RUN ln -s $(grep "wrapper.java.classpath.1" config/wrapper.conf | cut -d"/" -f 2) latest-version

ENTRYPOINT ["jre/bin/java", \
             "-cp", \
             "latest-version/lib/*", \
             "-server", \
             "-verbose:gc", \
             "-Xmx128m", \
             "-Xms32m", \
             "-XX:+UseParallelGC", \
             "-XX:+AggressiveOpts", \
             "-XX:+UseFastAccessorMethods", \
             "-XX:+DisableExplicitGC", \
             "-XX:+HeapDumpOnOutOfMemoryError", \
             "-Djava.library.path=latest-version/bin/native/lib", \
             "com.sumologic.scala.collector.Collector"]
