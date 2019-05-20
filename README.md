- [Sumo Logic Collector for Docker](#sumo-logic-collector-for-docker)
- [Use the Docker collection image](#use-the-docker-collection-image)
  * [Prerequisites and limitations](#prerequisites-and-limitations)
  * [Step 1 Create Sumo Access ID and Key](#step-1-create-sumo-access-id-and-key)
  * [Step 2 Tailor source configuration](#step-2-tailor-source-configuration)
    + [More about defining container filters](#more-about-defining-container-filters)
  * [Step 3 Run the image](#step-3-run-the-image)
    + [Collector environment variables](#collector-environment-variables)
    + [Configure collector in user.properties file](#configure-collector-in-userproperties-file)
    + [To monitor more than 40 containers](#to-monitor-more-than-40-containers)
    + [To avoid exposing your keys on the command line](#to-avoid-exposing-your-keys-on-the-command-line)
  * [Step 4 Install Sumo app for Docker](#step-4-install-sumo-app-for-docker)
  * [Step 5 Run searches and use dashboards](#step-5-run-searches-and-use-dashboards)
    + [Sample Docker messages](#sample-docker-messages)
    + [Sample query for containers created or started](#sample-query-for-containers-created-or-started)
- [Use the Syslog collection image](#use-the-syslog-collection-image)
- [Use the file collection image](#use-the-file-collection-image)
- [Create a custom Docker image](#create-a-custom-docker-image)
  * [Using source templates](#using-source-templates)



# Sumo Logic Collector for Docker

This repository offers several variants of Docker images to run the Sumo Logic collector. The batteries-included images contains one or more pre-configured sources. In Sumo, collectors use sources to collect data. The following images are available:

* Docker Collection—This batteries-included image runs the collector with Sumo’s Docker Logs source and Docker Stats source. This allows you to collect container logs, events, and stats, and to use the [Sumo web app for Docker](https://help.sumologic.com/Send-Data/Data-Types/Docker/Docker-App-Dashboards). For instructions on using this image, see [Use the Docker Collection Image](#use-the-docker-collection-image).

* Syslog Collection—This batteries-included image runs the collector with Sumo’s Syslog source. The collector will listen on port 514 TCP and UDP for Syslog traffic. For more information, see [Use the Syslog Collection Image](#use-the-syslog-collection-image).

* File Collection—This batteries-included image runs the collector with Sumo’s local file source. This allows you to collect all files from `/tmp/clogs/` from a Docker volume on the host. For more information, see [Use the File Collection Image](#use-the-file-collection-image).

* Custom Configuration—This is a base image you can use to build your own custom-configured collector image. For more information, see [Create a Custom Docker Image](#create-a-custom-docker-image).

When you run a collector image, the collector automatically registers with the Sumo service and creates sources based on a `sumo-sources.json` file. In each of the batteries-included images, the collector is configured to be ephemeral: it will be deleted automatically after being offline for 12 hours. For information about ephemeral collectors, see [Set a Collector as Ephemeral](https://help.sumologic.com/Send-Data/Installed-Collectors/05Reference-Information-for-Collector-Installation/11Set-a-Collector-as-Ephemeral), in Sumo help.

# Use the Docker collection image 

The batteries-included image tagged `latest` runs the collector with Sumo’s Docker Logs source and Docker Stats source. 

When run, the collector listens on the Docker Unix socket for container logs, events and stats. 

Sumo’s Docker Logs source and Docker Stats source use the Docker Engine API to gather the following data from Docker:

* Docker container logs. Sumo’s Docker Logs source collects container logs. For information about the API Sumo uses to collect logs, see [Get Container Logs](https://docs.docker.com/engine/api/v1.29/#operation/ContainerLogs) in Docker API documentation. 

* Docker events. Sumo’s Dockers log source collect Docker events. For information about Docker events, see [Monitor Events](https://docs.docker.com/engine/api/v1.29/#operation/SystemEvents) in Docker API documentation.

* Docker container stats. Sumo’s Docker stats source collects stats. For information about Docker stats, see [Get Container Stats Based on Resource Usage](https://docs.docker.com/engine/api/v1.29/#operation/ContainerExporthttps://docs.docker.com/engine/api/v1.29/#operation/ContainerExport) in Docker API documentation.

## Prerequisites and limitations
Before installing, review the [Installed Collector Requirements](https://help.sumologic.com/Start-Here/01About-Sumo-Logic/System-Requirements/Installed-Collector-Requirements) help page to understand the resource requirements of the installed collector.

The containers you’re going to monitor must use either the `json-file` or the `journald driver`. For more information, see [Configure Logging Drivers](https://docs.docker.com/engine/admin/logging/overview/) in Docker help.

By default, you can monitor up to 40 Docker containers on a Docker host. If you want to monitor more than 40 containers on a given host, see [To monitor more than 40 containers](#to-monitor-more-than-40-containers).

## Step 1 Create Sumo Access ID and Key

If you don’t already have a Sumo account, you can create one by clicking **Free Trial** on https://www.sumologic.com/.

Log into Sumo to create an access ID and an access key to register the Sumo collector. For instructions, see [Access Keys](https://help.sumologic.com/Manage/Security/Access-Keys) in Sumo help. Make a note of the access ID and access key. You supply these credentials when you start the Sumo collector.

## Step 2 Tailor source configuration 

There are two Sumo sources included in the image: Docker logs and Docker stats. The JSON file defines the sources is at https://github.com/SumoLogic/sumologic-collector-docker/blob/master/docker-sources/sumo-sources.json.  

The Docker logs source in the image collects container logs from all containers on a Docker host, and events. Processing of multiline log messages is not enabled. 

The Docker stats source collects Docker stats from all containers on a Docker host. The polling interval is set to one minute.  

If you want to change the configuration of one or both of the sources, you can create your own `sumo-sources.json` using https://github.com/SumoLogic/sumologic-collector-docker/blob/master/docker-sources/sumo-sources.json as a starting point.  

For example:

* If you only want to monitor Docker logs, remove the `Docker-stats` object from the `sources` array.

* If you want to collect logs and events from only selected containers, set `allContainers` in the `Docker-logs` object to `false`, and specify selected containers using `specifiedContainers`.  

* If you want to collect stats from only selected containers, set `allContainers` in the `Docker-stats` object to `false`, and specify selected containers using `specifiedContainers.` For more information, see [More about defining container filters]().

* If you want to prevent the Docker logs source from collecting events (start, stop, and so on) set `collectEvents` in the `Docker-logs` object to `false`.

For general information about configuring Docker sources, see [Docker log source](https://help.sumologic.com/Send-Data/Sources/03Use-JSON-to-Configure-Sources/JSON-Parameters-for-Installed-Sources#Docker_Log_Source) and [Docker stats source](https://help.sumologic.com/Send-Data/Sources/03Use-JSON-to-Configure-Sources/JSON-Parameters-for-Installed-Sources#Docker_Stats_Source) in Sumo help.

When you run the image, specify the location of your `sumo-sources.json` file using the `SUMO_SOURCES_JSON` environment variable. For information about using environment variables, see the [Collector environment variables](#collector-environment-variables) below. 

### More about defining container filters 

In the **Container Filter** field, you can enter a comma-separated list of one or more of the following types of filters:

* A specific container name, for example, “my-container”
* A wildcard filter, for example, “my-container-\*”
* An exclusion (blacklist) filter, which begins with an exclamation mark, for example, ”!master-container” or “!prod-\*”

For example, this filter list:

`prod-*, !prod-*-mysql, master-*-app-*, sumologic-collector`

will cause the source to collect from all containers whose names start with “prod-”, except those that match “prod-\*-mysql”. It will also collect from containers with names that match “master-\*-app-\*”, and from the “sumologic-collector” container.

If your filter list contains only exclusions, the source will collect all containers except from those that match your exclusion filters. For example:

`!container123*, !prod-*`

will cause the source to exclude containers whose names begin with “container123” and “prod-”.




## Step 3 Run the image 

To run the Docker Collection image, run the following command, supplying your access ID and access key.

`docker run -d -v /var/run/docker.sock:/var/run/docker.sock --name="sumo-logic-collector"  sumologic/collector:latest AccessID AccessKey`

The collector can be configured either with environment variables, or a volume-mounted `user.properties` file, as described in the sections below.

### Collector environment variables
The following environment variables are supported. You can pass environment variables to the `docker run` command with the `-e` flag.


|Environment Variable      |Description    |
|--------------------------|---------------|
|`SUMO_ACCESS_ID`            |Passes the Access ID.|
|`SUMO_ACCESS_KEY`           |Passes the Access Key.|
|`SUMO_ACCESS_ID_FILE`       |Passes a bound file path containing Access ID.|
|`SUMO_ACCESS_KEY_FILE`      |Passes a bound file path containing Access Key.|
|`SUMO_CLOBBER`              | When true, if there is an existing collector with the same name, that collector will be deleted.<br><br>Default: false|
|`SUMO_COLLECTOR_EPHEMERAL`  |When true, the collector will be deleted after it goes offline for 12 hours. <br><br>Default: true.|
|`SUMO_COLLECTOR_NAME`       |Configures the name of the collector. The default is set dynamically to the value in `/etc/hostname`.|
|`SUMO_COLLECTOR_NAME_PREFIX`|Configures a prefix to the collector name. Useful when overriding `SUMO_COLLECTOR_NAME` with the Docker hostname.<br><br>Default: "collector_container-"<br><br>If you do not want a prefix, set the variable as follows: <br><br>`SUMO_COLLECTOR_NAME_PREFIX = ""`|
|`SUMO_COLLECTOR_HOSTNAME`   |Sets the host name of the machine on which the Collector container is running.<br><br> Default: The container ID.|
|`SUMO_DISABLE_SCRIPTS`       |If your organization's internal policies restrict the use of scripts, you can disable the creation of script-based script sources. When this parameter is passed, this option is removed from the Sumo web application, and script source cannot be configured.<br><br> Default: false.|
|`SUMO_GENERATE_USER_PROPERTIES`|Set this variable to “false” if you are providing the collector configuration settings using a `user.properties` file via a Docker volume mount.|
|`SUMO_JAVA_MEMORY_INIT`      |Sets the initial java heap size (in MB). <br><br>Default: 64|
|`SUMO_JAVA_MEMORY_MAX`       |Sets the maximum java heap size (in MB). <br><br>Default: 128.|
|`SUMO_PROXY_HOST`            |Sets proxy host when a proxy server is used.|
|`SUMO_PROXY_NTLM_DOMAIN`     |Sets proxy NTLM domain when a proxy server is used with NTLM authentication.|
|`SUMO_PROXY_PASSWORD`        |Sets proxy password when a proxy server is used with authentication.|
|`SUMO_PROXY_PORT`            |Sets proxy port when a proxy server is used.|
|`SUMO_PROXY_USER`            |Sets proxy user when a proxy server is used with authentication.|
|`SUMO_SOURCES_JSON`          |Specifies the path to the `sumo-sources.json` file. <br><br>Default: `/etc/sumo-sources.json`. |
|`SUMO_SYNC_SOURCES`          |If “true”, the `SUMO_SOURCES_JSON` file(s) will be continuously monitored and synchronized with the Collector's configuration. This will also disable editing of the collector in the Sumo UI. <br><br>Default: false|
|`SUMO_FIPS_JCE`              |If "true", the FIPS 140-2 compliant Java Cryptography Extension (JCE) would be used to encrypt the data. <br><br>Default: false|

### Configure collector in user.properties file
You can supply source configuration values using a `user.properties` file via a Docker volume mount. For information about supported properties, see [user.properties](http://help.sumologic.com/Send_Data/Installed_Collectors/05Reference_Information_for_Collector_Installation/06user.properties) in Sumo help. For information about Docker volumes, see [Use Volumes](https://docs.docker.com/engine/admin/volumes/volumes/) in Docker help.

**Note** If you configure a source using `user.properties`, you cannot update the source configuration using the Sumo web app or the collector management API.

To use a custom `user.properties` file, you must pass the environment variable `SUMO_GENERATE_USER_PROPERTIES=false`, and provide the Docker volume mount to replace the file located at `/opt/SumoCollector/config/user.properties`.

For example:
```
docker run other options -e SUMO_GENERATE_USER_PROPERTIES=false -v $some_path/user.properties:/opt/SumoCollector/config/user.properties sumologic/collector:$tag
```

### To monitor more than 40 containers

By default, you can collect from up to 40 containers. To increase the limit:

1. Open a bash shell with the running collector container with either:

`docker exec -ti container_id /bin/bash`  

or 

`docker exec -ti container_name /bin/bash`

2. Edit the file located at `/opt/SumoCollector/config/collector.properties`, to add the `docker.maxPerContainerConnections` property. The maximum supported value is 100. 

3. Exit the shell.

4. Restart the container with either:

`docker restart container_id`

or 

`docker restart container_name`

### To avoid exposing your keys on the command line 

#### Use Docker Secret Management 

To prevent exposing your keys on the commandline, use the following command lines:

```
# be sure you have an up and running docker swarm cluster (1 node or more):
docker swarm init
# store your API keys using docker secret manager:
echo AccessID | docker secret create sumo-access-id
echo AccessKey | docker secret ceate sumo-access-key
docker service create --name sumologic-collector --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --mode global --secret sumo-access-id --secret sumo-secret-key -e SUMO_ACCESS_ID_FILE=/run/secret/sumo-access-id -e SUMO_ACCESS_KEY_FILE=/run/secrets/sumo-access-key sumologic/collector:latest
```
Using this commandline, the service will automatically be deployed to all nodes of your swarm cluster thanks to the _global_ mode.

#### Store and historize your configuration with docker-compose file and docker stack

You can automate your swarm cluster creation using docker-compose file together with the docker stack command and docker secret management.

```
# be sure you have an up and running docker swarm cluster (1 node or more):
docker swarm init
# store your API keys using docker secret manager:
echo AccessID | docker secret create sumo-access-id
echo AccessKey | docker secret ceate sumo-access-key

cat > docker-compose.yml <<EOF
version: '3.2'

services:

  sumologic:
    image: sumologic/collector:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    deploy:
      mode: global
    secrets:
      - sumo-access-id
      - sumo-access-key
    environment:
      SUMO_ACCESS_ID_FILE: /run/secrets/sumo-access-id
      SUMO_ACCESS_KEY_FILE: /run/secrets/sumo-access-key

secrets:
  sumo-access-id:
    external: true
  sumo-access-key:
    external: true

EOF
docker stack deploy --compose-file docker-compose.yml sumologic
```


## Step 4 Install Sumo app for Docker
The Sumo app for Docker provides operational insight into your Docker containers. The app includes dashboards that allow you to view container performance statistics for CPU, memory, and the network. It also provides visibility into container events such as start, stop, and so on.

For installation instructions, see [Install the Docker App](https://help.sumologic.com/Send-Data/Data-Types/Docker/02-Install-the-Docker-App).

## Step 5 Run searches and use dashboards

At this point, Sumo should be receiving Docker data. For an example of logs collected from Docker, see [Sample Docker messages](#sample-docker-messages). For an example query, see [Sample query for containers created or started](#sample-query-for-containers-created-or-started).  

For information about the dashboards provided by the Sumo app for Docker, see [Docker App Dashboards](https://help.sumologic.com/Send-Data/Data-Types/Docker/Docker-App-Dashboards).

### Sample Docker messages 
This is an example of two Docker event logs:
```
{"status":"start", "id":"10adec58fa15202e06afef7b1b0b3b1464962a115ff56918444c3f22867d3f3b", "from":"hello-world", "time":1485975967}

{"status":"create", "id":"045599bc4d589264658f5f7f4efa3f1e3af9088ba1f7383a160cf344e1055d46", "from":"ubuntu", "time":1485966852}
```
This is an example of a Docker stats message:
```
{"read" : "2017-02-01T19:36:48.777487188Z", "network" : {"rx_bytes":87977,"rx_dropped":0,"rx_errors":0,"rx_packets":252,"tx_bytes":146194,"tx_dropped":0,"tx_errors":0,"tx_packets":302}, "cpu_stats" : {"cpu_usage":{"percpu_usage":[9469809313],"total_usage":9469809313,"usage_in_kernelmode":1050000000,"usage_in_usermode":8410000000},"system_cpu_usage":2496992710000000,"throttling_data":{"periods":0,"throttled_periods":0,"throttled_time":0}}, "blkio_stats" : {"io_merged_recursive":[],"io_queue_recursive":[],"io_service_bytes_recursive":[],"io_service_time_recursive":[],"io_serviced_recursive":[],"io_time_recursive":[],"io_wait_time_recursive":[],"sectors_recursive":[]}, "memory_stats" : {"limit":1033252864,"max_usage":202858496,"stats":{"active_anon":86831104,"active_file":13131776,"cache":24981504,"dirty":36864,"hierarchical_memory_limit":9223372036854771712,"inactive_anon":86786048,"inactive_file":11849728,"mapped_file":6430720,"pgfault":63351,"pgmajfault":146,"pgpgin":68526,"pgpgout":20040,"rss":173617152,"rss_huge":0,"total_active_anon":86831104,"total_active_file":13131776,"total_cache":24981504,"total_dirty":36864,"total_inactive_anon":86786048,"total_inactive_file":11849728,"total_mapped_file":6430720,"total_pgfault":63351,"total_pgmajfault":146,"total_pgpgin":68526,"total_pgpgout":20040,"total_rss":173617152,"total_rss_huge":0,"total_unevictable":0,"total_writeback":0,"unevictable":0,"writeback":0},"usage":201818112}}
```

### Sample query for containers created or started
```
_sourceCategory=docker  ("\"status\":\"create\"" or "\"status\":\"start\"")  id from
| parse "\"status\":\"*\"" as status, "\"id\":\"*\"" as container_id, "\"from\":\"*\"" as image
| count_distinct(container_id)
```

# Use the Syslog collection image

The batteries-included Syslog image is tagged `latest-syslog`. When you run it, the collector listens on port 514 for TCP and UDP Syslog traffic. 

To run the Syslog collection image, run the following command, supplying your access ID and access key. If you have not created the credentials yet, see [Create Sumo Access ID and Key](#step-1-create-sumo-access-id-and-key).

`docker run -d -p 514:514 -p 514:514/udp --name="sumo-logic-collector" sumologic/collector:latest-syslog Access ID Access key`

Configuration options:

* Collector configuration. You can configure optional collector behaviors by supplying environment variables on the command line, or in a `user.properties fil`e. For more information, see [Collector Environment Variables](#collector-environment-variables) and [Configure Collector in user.properties File](#configure-collector-in-user.properties-file).

* Sources configuration. You can see the sumo-sources.json in the image at https://github.com/SumoLogic/sumologic-collector-docker/blob/master/syslog/sumo-sources.json. If you want to tailor the source configuration, create a new `sumo-sources.json`. When you run the image, specify the location of your `sumo-sources.json` file using the `SUMO_SOURCES_JSON` environment variable. 

# Use the file collection image
Another "batteries included" image is available and tagged latest-file. When run, the collector collects all files from `/tmp/clogs/`. Docker volumes need to be used to make logs available in this directory. 

To run the file collection image, run the following command, supplying your access ID and access key. If you have not created the credentials yet, see [Create Sumo Access ID and Key](#step-1-create-sumo-access-id-and-key).

`docker run -v /tmp/clogs:/tmp/clogs -d --name="sumo-logic-collector" sumologic/collector:latest-file Access ID Access Key`

You can use the [/etc/sumo-containers.json](https://github.com/SumoLogic/sumologic-collector-docker/blob/master/file/sumo-containers.json) source file to collect logs from all containers.

```
docker run -v /var/lib/docker/containers:/var/lib/docker/containers:ro -d --name="sumo-logic-collector" -e SUMO_SOURCES_JSON=/etc/sumo-containers.json sumologic/collector:latest-file Access ID Access Key 
```

Configuration options:

* Collector configuration. You can configure optional collector behaviors by supplying environment variables on the command line, or in a user.properties file. For more information, see [Collector Environment Variables](#collector-environment-variables) and [Configure Collector in user.properties File](#configure-collector-in-user.properties-file).

* Sources configuration. You can see the sumo-sources.json in the image at https://github.com/SumoLogic/sumologic-collector-docker/blob/master/file/sumo-containers.json. If you want to tailor the source configuration, create a new `sumo-sources.json`. When you run the image, specify the location of your `sumo-sources.json` file using the `SUMO_SOURCES_JSON` environment variable. 


# Create a custom Docker image
A base image to build your own image with a custom configuration is tagged latest-no-source. You must add `/etc/sumo-sources.json` to run it. This is the configuration file that specifies the sources, metadata, and settings that the collector should monitor.

Examples are available in example in [GitHub](https://github.com/SumoLogic/sumologic-collector-docker/tree/master/example), along with some example configuration files. Pick one of the examples and rename it to `sumo-sources.json` or create one from scratch. For more information, see [Use JSON to Configure Sources](https://help.sumologic.com/Send-Data/Sources/03Use-JSON-to-Configure-Sources) in Sumo help.

After configuring a `sumo-sources.json` file, create a Dockerfile similar to the one below:

```
FROM sumologic/collector:latest-no-source
MAINTAINER Happy Sumo Customer
ADD sumo-sources.json /etc/sumo-sources.json
```

Build an image with your configuration:

`docker build --tag="yourname/sumocollector"`

To run your image, run the command below, supplying your access ID and access key.  If you have not created the credentials yet, see [Create Sumo Access ID and Key](#step-1-create-sumo-access-id-and-key).

`docker run -d --name="sumo-logic-collector" yourname/sumocollector Access ID Access Key`


Depending on the configuration of your sources, additional command line parameters may be required to create the container.

## Using source templates
The collector image supports source JSON configuration templates allowing for string substitution using environment variables. This works by finding all files with a .json.tmpl extension, looping through all environment variables and replacing the values. Finally the file is renamed to .json.

**Note** You can also create your own docker image with the tmpl files embedded rather than a volume mount.

For example, if the container was started with the following environment variables and file `/etc/sumo-containers.json.tmpl`:

```
docker run -v /var/lib/docker/containers:/var/lib/docker/containers:ro -v /path/to/sources:/sumo  -d --name="sumo-logic-collector" -e SUMO_SOURCES_JSON=/sumo/sources.json -e ENVIRONMENT=prod sumologic/collector:latest-file Access ID Access Key
```

File /path/to/sources/sources.json.tmpl

```
{
  "api.version": "v1",
  "sources": [
    {
      "sourceType" : "LocalFile",
      "name": "localfile-collector-container",
      "pathExpression": "/var/lib/docker/containers/**/*.log",
      "category": "${ENVIRONMENT}/containers"
    }
  ]
}
```

The resulting output of `/sumo/sources.json` will be
```
{
  "api.version": "v1",
  "sources": [
    {
      "sourceType" : "LocalFile",
      "name": "localfile-collector-container",
      "pathExpression": "/var/lib/docker/containers/**/*.log",
      "category": "prod/containers"
    }
  ]
}
```
