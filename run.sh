#!/bin/bash

if [[ $SUMO_ACCESS_ID_FILE ]]; then
  export SUMO_ACCESS_ID=$(cat $SUMO_ACCESS_ID_FILE)
fi

if [[ $SUMO_ACCESS_KEY_FILE ]]; then
  export SUMO_ACCESS_KEY=$(cat $SUMO_ACCESS_KEY_FILE)
fi

SUMO_GENERATE_USER_PROPERTIES=${SUMO_GENERATE_USER_PROPERTIES:=true}
SUMO_ACCESS_ID=${SUMO_ACCESS_ID:=$1}
SUMO_ACCESS_KEY=${SUMO_ACCESS_KEY:=$2}
SUMO_RECEIVER_URL=${SUMO_RECEIVER_URL:=https://collectors.sumologic.com}
# Handle case for an empty string
SUMO_COLLECTOR_NAME=${SUMO_COLLECTOR_NAME_PREFIX='collector_container-'}${SUMO_COLLECTOR_NAME:=$(cat /etc/hostname)}
SUMO_SOURCES_JSON=${SUMO_SOURCES_JSON:=/etc/sumo-sources.json}
SUMO_SYNC_SOURCES=${SUMO_SYNC_SOURCES:=false}
SUMO_COLLECTOR_EPHEMERAL=${SUMO_COLLECTOR_EPHEMERAL:=true}
SUMO_COLLECTOR_HOSTNAME=${SUMO_COLLECTOR_HOSTNAME:=$(cat /etc/hostname)}

generate_user_properties_file() {
    if [ -z "$SUMO_ACCESS_ID" ] || [ -z "$SUMO_ACCESS_KEY" ]; then
      echo "FATAL: Please provide credentials, either via the SUMO_ACCESS_ID and SUMO_ACCESS_KEY environment variables,"
      echo "       as the first two command line arguments,"
      echo "       or in files references by SUMO_ACCESS_ID_FILE and SUMO_ACCESS_KEY_FILE!"
      exit 1
    fi

    # Support using env as replacement within sources.
    # Gather all template files
    declare -a TEMPLATE_FILES
    if [ -r "${SUMO_SOURCES_JSON}.tmpl" ]; then
        TEMPLATE_FILES+=("${SUMO_SOURCES_JSON}.tmpl")
    fi
    if [ -d "${SUMO_SOURCES_JSON}" ]; then
        for f in $(find ${SUMO_SOURCES_JSON} -name '*.tmpl'); do TEMPLATE_FILES+=(${f}); done
    fi

    for from in "${TEMPLATE_FILES[@]}"
    do
        # Replace all env variables and remove .tmpl extension
        to=${from%.*}
        echo > ${to}
        if [ $? -ne 0 ]; then
            echo "FATAL: unable to write to ${to}"
            exit 1
        fi

        OLD_IFS=$IFS
        IFS=$'\n'
        while read -r line; do
          line_escape_backslashes=${line//\\/\\\\}
          printf "%s\n" "$(eval echo "\"${line_escape_backslashes//\"/\\\"}\"")" >> ${to}
        done <${from}
        IFS=${OLD_IFS}

        echo "INFO: Replacing environment variables from ${from} into ${to}"

    done

    if [ ! -e "${SUMO_SOURCES_JSON}" ]; then
      echo "FATAL: Unable to find $SUMO_SOURCES_JSON - please make sure you include it in your image!"
      exit 1
    fi

    if [ "${SUMO_SYNC_SOURCES}" == "true" ]; then
        SUMO_SYNC_SOURCES=${SUMO_SOURCES_JSON}
        unset SUMO_SOURCES_JSON
    else
        unset SUMO_SYNC_SOURCES
    fi

    # Supported user.properties configuration parameters
    # More information https://help.sumologic.com/Send_Data/Installed_Collectors/stu_user.properties
    declare -A SUPPORTED_OPTIONS
    SUPPORTED_OPTIONS=(
        ["SUMO_ACCESS_ID"]="accessid"
        ["SUMO_ACCESS_KEY"]="accesskey"
        ["SUMO_RECEIVER_URL"]="url"
        ["SUMO_COLLECTOR_NAME"]="name"
        ["SUMO_COLLECTOR_HOSTNAME"]="hostName"
        ["SUMO_SOURCES_JSON"]="sources"
        ["SUMO_SYNC_SOURCES"]="syncSources"
        ["SUMO_COLLECTOR_EPHEMERAL"]="ephemeral"
        ["SUMO_PROXY_HOST"]="proxyHost"
        ["SUMO_PROXY_PORT"]="proxyPort"
        ["SUMO_PROXY_USER"]="proxyUser"
        ["SUMO_PROXY_PASSWORD"]="proxyPassword"
        ["SUMO_PROXY_NTLM_DOMAIN"]="proxyNtlmDomain"
        ["SUMO_CLOBBER"]="clobber"
        ["SUMO_DISABLE_SCRIPTS"]="disableScriptSource"
        ["SUMO_JAVA_MEMORY_INIT"]="wrapper.java.initmemory"
        ["SUMO_JAVA_MEMORY_MAX"]="wrapper.java.maxmemory"
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
}

# If the user didn't supply their own user.properties file, generate it
$SUMO_GENERATE_USER_PROPERTIES && {
    generate_user_properties_file
}

# Don't leave our shell hanging around
exec /opt/SumoCollector/collector console
