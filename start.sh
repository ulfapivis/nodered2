#!/bin/bash

# load flows.json if specified
if [ -n "${FLOW_DATA}" ]; then
    echo "$FLOW_DATA" > /data/flows.json
else
    echo "No flows.json"
fi

# Verify if the file was created
ls -l /settings.js

# load if specified
if [ -n "${NODE_RED_FLOW_CRED}" ]; then
    echo "$NODE_RED_FLOW_CRED" > /data/flows_cred.json
else
    echo "No flows_cred.json"
fi

# Install custom nodes if specified
if [ -n "${CUSTOM_NODES}" ]; then
    npm install $(echo ${CUSTOM_NODES})
else
    echo "No custom nodes specified"
fi

# Start Node-RED

if [ -n "${ALLOWED_IPS}" ]; then
    node-red -s /settings_noip.js
else
    node-red -s /settings.js
fi




