# Sumo Logic Collector for Docker

This creates a base image for a Sumo Logic collector, i.e. "no batteries included". In order to run the collector, you need to create
an image based on `sumologic/collector` that adds `/etc/sumo-sources.json` with your preferred settings. An example of such a `Dockerfile`
is included in `example`, along with some example configuration files to show how sources can be configured in the collector. Pick one of the examples and rename to ``sumo-sources.json``.

Alternatively, create your own sumo-sources.json configuration file using the help available here: https://service.sumologic.com/help/Using_JSON_to_configure_Sources.htm.

After configuring a ``sumo-sources.json`` file, build an image with your configuration:

```bash
docker build  .
```

Create an access ID and an access key (https://service.sumologic.com/help/Default.htm#Generating_Collector_Installation_API_Keys.htm?Highlight=access%20id) in the Sumo Logic service and plug them into the below commandline to run the container:

```bash
docker run -i -t -e "SUMO_ACCESS_ID=[your ID]" -e "SUMO_ACCESS_KEY=[your-access-key]" [image]
```

Depending on the source setup, additional commandline parameters will be needed to create container.

If you are using the ``sumo-sources.json.file.example`` configuration file verbatim, the collector will collect all files in ``/logs`` in the container. If you want to say collect all logs from the hosts ``/var/log``, create the container with a mapped volume:

```bash
docker run -e "SUMO_ACCESS_ID=[your ID]" -e "SUMO_ACCESS_KEY=[your-access-key]" -v /var/log:/logs [image]
```

If you are using the Syslog TCP example, you need to map port 514 to a port on the host. The ``-P`` option will automatically map all exposed ports.

```bash
docker run -e "SUMO_ACCESS_ID=[your ID]" -e "SUMO_ACCESS_KEY=[your-access-key]" -P [image]
```
