# auto-build: {"image_name": "sumologic/collector", "tags": ["latest-syslog"], "calver_prefix": "syslog-"}
FROM sumologic/collector:latest-no-source
MAINTAINER Sumo Logic <docker@sumologic.com>
ADD sumo-sources.json /etc/sumo-sources.json
EXPOSE 514/udp
EXPOSE 514
