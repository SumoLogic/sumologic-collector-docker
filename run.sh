#!/bin/bash

if [ $# = 2 ]; then
	if [ -z "$SUMO_ACCESS_ID" ]; then
		SUMO_ACCESS_ID="$1"
	fi

	if [ -z "$SUMO_ACCESS_KEY" ]; then
		SUMO_ACCESS_KEY="$2"
	fi
fi

if [ -z "$SUMO_ACCESS_ID" ] || [ -z "$SUMO_ACCESS_KEY" ]; then
	echo "Please provide credentials, either via the SUMO_ACCESS_ID and SUMO_ACCESS_KEY environment variables,"
	echo "or as the first two command line arguments!"
	exit 1
fi

/opt/SumoCollector/collector console -- -t -i $SUMO_ACCESS_ID -k $SUMO_ACCESS_KEY