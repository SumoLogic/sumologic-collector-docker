# Sumo Logic Collector for Docker

There are some example files in this repositoy to show how sources can be configured in the collector. Pick one of the examples and rename to ``sumo-sources.json``.

Alternatively, create your own sumo-sources.json configuration file using the help available here: https://service.sumologic.com/help/Using_JSON_to_configure_Sources.htm.

After creating a ``sumo-sources.json`` file, build the image:

```bash
docker build -t="sumologic/collector" .
```

Create an access ID and an access key (https://service.sumologic.com/help/Default.htm#Generating_Collector_Installation_API_Keys.htm?Highlight=access%20id) in the Sumo Logic service and plug them into the below commandline to run the container:

```bash
docker run -i -t -e "SUMO_ACCESS_ID=[your ID]" -e "SUMO_ACCESS_KEY=[your-access-key]" sumologic/collector
```

Depending on the source setup, additional commandline parameters will be needed to create container.

If you are using the ``sumo-sources.json.file.example`` configuration file verbatim, the collector will collect all files in ``/logs`` in the container. If you want to say collect all logs from the hosts ``/var/log``, create the container with a mapped volume:

```bash
docker run -i -t -e "SUMO_ACCESS_ID=[your ID]" -e "SUMO_ACCESS_KEY=[your-access-key]" -v /var/log:/logs sumologic/collector
```

If you are using the Syslog TCP example, you need to map port 514 to a port on the host. The ``-P`` option will automatically map all exposed ports.

```bash
docker run -i -t -e "SUMO_ACCESS_ID=[your ID]" -e "SUMO_ACCESS_KEY=[your-access-key]" -P sumologic/collector
```
