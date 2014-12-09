# Sumo Logic Collector for Docker

A container with a syslog source both for UDP and TCP, plus a file source that will collect everything in /logs - mount whatever you want to /logs.

There are some example files in this repositoy to show how sources can be configured in the collector. Pick one of the examples and rename to ``sumo-sources.json``.

Alternatively, create your own sumo-sources.json configuration file using the help available here: https://service.sumologic.com/help/Using_JSON_to_configure_Sources.htm.

After creating a ``sumo-sources.json`` file, build the image:

```bash
docker build -t="sumologic/collector" .
```

Create an access ID and an access key (https://service.sumologic.com/help/Default.htm#Generating_Collector_Installation_API_Keys.htm?Highlight=access%20id) in the Sumo Logic service and plug them into the below commandline to run the container:

```bash
docker run -i -t -e "SUMO_ACCESS_ID=[your ID]" -e "SUMO_ACCESS_KEY=[your-access-key]" -P -v /var/log:/logs sumologic/collector
```