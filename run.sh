#!/usr/bin/env bash

set -x

access_id=${SUMO_ACCESS_ID:=$1}
access_key=${SUMO_ACCESS_KEY:=$2}
receiver_url=${SUMO_RECEIVER_URL:=https://collectors.sumologic.com}
collector_name=${SUMO_COLLECTOR_NAME:=collector_container}
sources_json=${SUMO_SOURCES_JSON:=/etc/sumo-sources.json}

if [ -z "$access_id" ] || [ -z "$access_key" ]; then
  echo "FATAL: Please provide credentials, either via the SUMO_ACCESS_ID and SUMO_ACCESS_KEY environment variables,"
  echo "       or as the first two command line arguments!"
  exit 1
fi

if [ ! -e "$sources_json" ]; then
  echo "FATAL: Unable to find $sources_json - please make sure you include it in your image!"
  exit 1
fi

sed -i "s/wrapper.java.initmemory=.*/wrapper.java.initmemory=$COLLECTOR_MEM/g" /opt/SumoCollector/config/wrapper.conf
sed -i "s/wrapper.java.maxmemory=.*/wrapper.java.maxmemory=$COLLECTOR_MEM/g" /opt/SumoCollector/config/wrapper.conf
if [ "$WRAPPER_DEBUG" == "TRUE" ]; then
  sed -i "s/#\ wrapper.debug=.*/wrapper.debug=TRUE/g" /opt/SumoCollector/config/wrapper.conf
fi
if [ "$LOG_TO_STDOUT" == "TRUE" ]; then
  sed -i "s/wrapper.logfile=.*/wrapper.logfile=/dev/stdout" /opt/SumoCollector/config/wrapper.conf
fi

/opt/SumoCollector/collector console -- -t -i $access_id -k $access_key -n $collector_name -s $sources_json -u $receiver_url
