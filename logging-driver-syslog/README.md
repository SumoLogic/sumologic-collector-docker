Syslog Logging Driver With Sumo Logic
=====================================

If you want to build the image locally yourself:

```bash
$ docker build -t logging-driver-syslog .
```

Run that image:

```bash
$ docker run -v /var/log/syslog:/syslog -d --name="sumo-logic-collector" logging-driver-syslog [Access ID] [Access Key]
```

It is recommended to use the official image from Docker Hub:

```bash
$ docker run -v /var/log/syslog:/syslog -d --name="sumo-logic-collector" sumologic/collector:latest-logging-driver-syslog [Access ID] [Access Key]
```

Of course, all containers need to be run with ```--logging-driver=syslog``` for this to work.