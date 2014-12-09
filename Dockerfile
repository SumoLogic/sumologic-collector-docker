# Sumo Logic Collector Docker Image
# Version 0.1

FROM ubuntu:14.04
MAINTAINER Christian Beedgen
ADD https://collectors.sumologic.com/rest/download/deb/64 /tmp/collector.deb
RUN dpkg -i /tmp/collector.deb
EXPOSE 514/udp
EXPOSE 514
ADD sumo-sources.json /etc/sumo-sources.json
ADD sumo.conf /etc/sumo.conf
ENV SUMO_ACCESS_KEY your-id-here
ENV SUMO_ACCESS_ID your-key-here
ENV SUMO_COLLECTOR_NAME collector-container
ENV SUMO_SOURCES_JSON /etc/sumo-sources.json
CMD /opt/SumoCollector/collector console -- -t -i $SUMO_ACCESS_ID -k $SUMO_ACCESS_KEY -n $SUMO_COLLECTOR_NAME -s $SUMO_SOURCES_JSON