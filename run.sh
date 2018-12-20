#!/bin/bash
################################################################################
# SFIQ customization: begin
################################################################################

# read EC2 tags
tags_str=$(/usr/local/bin/aws-instance-metadata-reader)
IFS=',' read -ra tags <<< ${tags_str}

# get customized sumo category metadata, first from env var, then from ec2 tags
# before using the default value
if [[ -z "$SUMO_CATEGORY" ]]; then
  for tag_pair in ${tags[@]}; do
  pair=(${tag_pair//:/ })
  if [ ${#pair[@]} -eq 2 ]; then # ignore aws built-in tags with multiple `:`s in tag key
    if [ "${pair[0]}" == "SumoCategory" ]; then
       SUMO_CATEGORY="${pair[1]}"
    fi
  fi
  done
fi

SUMO_CATEGORY=${SUMO_CATEGORY:-ap/default}

if [[ -n "$SUMO_CATEGORY" ]]; then
    sed -i.bk 's,SUMO_CATEGORY_PLACEHOLDER,'"${SUMO_CATEGORY}"',g' /etc/sumo-sources.json
fi

# get customized sumo monitor file path expression, first from env var, then from ec2 tags
# before using the default value
if [[ -z "$SUMO_MONITOR_PATH" ]]; then
  for tag_pair in ${tags[@]}; do
  pair=(${tag_pair//:/ })
  if [ ${#pair[@]} -eq 2 ]; then # ignore aws built-in tags with multiple `:`s in tag key
    if [ "${pair[0]}" == "SumoMonitorPath" ]; then
       SUMO_MONITOR_PATH="${pair[1]}"
    fi
  fi
  done
fi

SUMO_MONITOR_PATH=${SUMO_MONITOR_PATH:-/logs/*/*.log}

if [[ -n "$SUMO_MONITOR_PATH" ]]; then
    sed -i.bk 's,SUMO_MONITOR_PATH_PLACEHOLDER,'"${SUMO_MONITOR_PATH}"',g' /etc/sumo-sources.json
fi


# get sumo creds from vault
viq login
export SUMO_ACCESS_ID=$(viq kv get -p ops_secret/sumologic/access_id)
export SUMO_ACCESS_KEY=$(viq kv get -p ops_secret/sumologic/access_key)
################################################################################
# SFIQ customization: end
################################################################################

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

if [ ! -e $sources_json ]; then
    echo "FATAL: Unable to find $sources_json - please make sure you include it in your image!"
    exit 1
fi

export SUMO_SOURCES_JSON=${sources_json}

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
SUMO_COLLECTOR_NAME=${SUMO_COLLECTOR_NAME_PREFIX:='collector_container-'}${SUMO_COLLECTOR_NAME:=`cat /etc/hostname`}
SUMO_SOURCES_JSON=${SUMO_SOURCES_JSON:=/etc/sumo-sources.json}
SUMO_SYNC_SOURCES=${SUMO_SYNC_SOURCES:=false}

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
        while read line; do
          line_escape_backslashes=${line//\\/\\\\\\\\}
          echo $(eval echo "\"${line_escape_backslashes//\"/\\\"}\"") >> ${to}
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
        ["SUMO_SOURCES_JSON"]="sources"
        ["SUMO_SYNC_SOURCES"]="syncSources"
        ["SUMO_PROXY_HOST"]="proxyHost"
        ["SUMO_PROXY_PORT"]="proxyPort"
        ["SUMO_PROXY_USER"]="proxyUser"
        ["SUMO_PROXY_PASSWORD"]="proxyPassword"
        ["SUMO_PROXY_NTLM_DOMAIN" ]="proxyNtlmDomain"
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




# The -t flag will force the collector to run as ephemeral
# Don't leave our shell hanging around
exec /opt/SumoCollector/collector console -- -t
