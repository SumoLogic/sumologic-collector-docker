#!/bin/bash

ACCESS_ID=${SUMO_ACCESS_ID:=$1}
ACCESS_KEY=${SUMO_ACCESS_KEY:=$2}
RECEIVER_URL=${SUMO_RECEIVER_URL:=https://collectors.sumologic.com}
COLLECTOR_NAME=${SUMO_COLLECTOR_NAME_PREFIX:=''}${SUMO_COLLECTOR_NAME:=`cat /etc/hostname`}
SOURCES_JSON=${SUMO_SOURCES_JSON:=/etc/sumo-sources.json}

if [ -z "$ACCESS_ID" ] || [ -z "$ACCESS_KEY" ]; then
	echo "FATAL: Please provide credentials, either via the SUMO_ACCESS_ID and SUMO_ACCESS_KEY environment variables,"
	echo "       or as the first two command line arguments!"
	exit 1
fi

if [ ! -e "${SOURCES_JSON}" ]; then
	echo "FATAL: Unable to find $SOURCES_JSON - please make sure you include it in your image!"
	exit 1
fi

# Supported user.properties configuration parameters
# https://help.sumologic.com/Send_Data/Installed_Collectors/stu_user.properties
declare -A SUPPORTED_OPTIONS
SUPPORTED_OPTIONS=(
    ["PROXY_HOST"]="proxyHost"
    ["PROXY_PORT"]="proxyPort"
    ["PROXY_USER"]="proxyUser"
    ["PROXY_PASSWORD"]="proxyPassword"
    ["PROXY_NTLM_DOMAIN" ]="proxyNtlmDomain"
    ["CLOBBER"]="clobber"
    ["DISABLE_SCRIPTS"]="disableScriptSource"
    ["JAVA_MEMORY_INIT"]="wrapper.java.initmemory"
    ["JAVA_MEMORY_MAX"]="wrapper.java.maxmemory"
)

USER_PROPERTIES=""

for key in "${!SUPPORTED_OPTIONS[@]}"
do
    value=${!key}
    if [ -n "${value}" ]; then
        USER_PROPERTIES="${USER_PROPERTIES}${SUPPORTED_OPTIONS[$key]}=${value}\n"
    fi
done

if [ -n "${USER_PROPERTIES}" ]; then
    echo -e ${USER_PROPERTIES} > /opt/SumoCollector/config/user.properties
fi

/opt/SumoCollector/collector console -- -t -i ${ACCESS_ID} -k ${ACCESS_KEY} -n ${COLLECTOR_NAME} -s ${SOURCES_JSON} -u ${RECEIVER_URL}
