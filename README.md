# Sumo Logic Collector for Docker

Create an access ID and an access key (https://service.sumologic.com/help/Default.htm#Generating_Collector_Installation_API_Keys.htm) in the Sumo Logic service to use these images. 

### Syslog Image

A simple "batteries included" syslog image is available and tagged `latest-syslog`. It needs no further configuration. It listens on port 514 TCP and UDP for syslog traffic. To run it, simply plug your access ID and an access key into the commandline below:


```bash
docker run docker run -d -p 514:514 -p 514:514/udp --name="sumo-logic-collector" sumologic/collector:latest-syslog sumologic/collector:latest-syslog [your Access ID] [your Access-key] 
```

### Base Image

A base image for a Sumo Logic collector, i.e. "no batteries included". In order to run the collector, you need to create
an image based on `sumologic/collector:latest` that adds `/etc/sumo-sources.json` with your preferred settings. An example of such a `Dockerfile` is included in `example` (in GitHub), along with some example configuration files to show how sources can be configured in the collector. Pick one of the examples and rename to ``sumo-sources.json``.

Alternatively, create your own `sumo-sources.json` configuration file using the help available here: https://service.sumologic.com/help/Using_JSON_to_configure_Sources.htm.

After configuring a `sumo-sources.json` file, build an image with your configuration:

```bash
docker build --tag="yourname/sumocollector" .
```

Plug your access ID and an access key into the commandline below to run the container:

```bash
docker run yourname/sumocollector [your Access ID] [your Access-key] 
```

Depending on the source setup, additional commandline parameters will be needed to create container.

If you are using the ``sumo-sources.json.file.example`` configuration file verbatim, the collector will collect all files in ``/logs`` in the container. If you want to say collect all logs from the hosts ``/var/log``, create the container with a mapped volume:

```bash
docker run -v /var/log:/logs yourname/sumocollector [your Access ID] [your Access-key] 
```