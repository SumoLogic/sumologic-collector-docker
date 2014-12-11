# Sumo Logic Collector for Docker

This repository offers several variants of Docker images to run the Sumo Logic Collector. When images are run, the Collector automatically registers with the Sumo Logic service and create sources based on a `sumo-sources.json` file. The Collector is configured [ephemeral](https://service.sumologic.com/help/Ephemeral.htm).

### Configuration

##### Environment variables

The following environment variables are supported: 

* `SUMO_ACCESS_ID` - Can be used to pass the access ID instead of passing it in as a commandline argument.
* `SUMO_ACCESS_KEY` - Can be used to pass the access key instead of passing it in as a commandline argument.
* `SUMO_COLLECTOR_NAME` - Allows configuring the name of the Collector. The default is _collector_container_. 
* `SUMO_SOURCES_JSON` - Allows specifying the path of the `sumo-sources.json` file. The default is `/etc/sumo-sources.json`. 

##### Credentials

All variants require a set of Collector credentials. Log into Sumo Logic and create an access ID and an access key to use when running the Collector images. See our [online help](https://service.sumologic.com/help/Default.htm#Generating_Collector_Installation_API_Keys.htm) for instructions.

### Variants

##### Syslog Collection

A simple "batteries included" syslog image is available and tagged `latest-syslog`. When run, the Collector listens on port 514 TCP and UDP for syslog traffic. Simply plug your access ID and an access key into the commandline below:


```bash
docker run docker run -d -p 514:514 -p 514:514/udp --name="sumo-logic-collector" sumologic/collector:latest-syslog [your Access ID] [your Access key] 
```

##### File Collection

Another "batteries included" image is available and tagged `latest-file`. When run, the Collector collects all files from `/tmp/clogs/`. Docker volumes need to be used to make logs available in this directory. Plug your credentials into the commandline below and adjust the 
volume options as needed: 

```bash
docker run docker run -v /tmp/clogs:/tmp/clogs -d --name="sumo-logic-collector" sumologic/collector:latest-file [your Access ID] [your Access key] 
```

##### Custom Configuration

A base image to build your own image with a custom configuration is tagged `latest`. You need to add  `/etc/sumo-sources.json` to run it. 
Examples are available in `example` [in GitHub](https://github.com/SumoLogic/sumologic-collector-docker/tree/master/example), along with some example configuration files. Pick one of the examples and rename to `sumo-sources.json` or create one from scratch. See  our [online help](https://service.sumologic.com/help/Using_JSON_to_configure_Sources.htm) for more details.

After configuring a `sumo-sources.json` file, create a `Dockerfile` similar to the one below: 

```
FROM sumologic/collector:latest
MAINTAINER Happy Sumo Customer
ADD sumo-sources.json /etc/sumo-sources.json
```

Build an image with your configuration:

```bash
docker build --tag="yourname/sumocollector" .
```

To run your image, plug your access ID and an access key into the commandline below to run the container:

```bash
docker run -d --name="sumo-logic-collector" yourname/sumocollector [your Access ID] [your Access key] 
```

Depending on the source setup, additional commandline parameters will be needed to create container.