#!/bin/bash

# shellcheck disable=SC1091 
# Path is relative to the Dockerfile
. /etc/profile

# These functions are in dvt_lsd_tools.sh: https://github.com/dappnode/staker-package-scripts/blob/main/scripts/dvt_lsd_tools.sh
EXECUTION_RPC=$(get_execution_rpc_api_url_from_global_env "$NETWORK")
EXECUTION_WS=$(get_execution_ws_url_from_global_env "$NETWORK")
BEACON_NODES=$(get_beacon_api_url_from_global_env "$NETWORK")

# If builder-proposals is selected to be "true" in the CONFIG, we add this flag when starting Anchor
if [ "${BUILDER_PROPOSALS}" = "true" ]; then
    echo "[INFO - entrypoint] Builder-proposals is enabled"
    EXTRA_OPTS=$(add_flag_to_extra_opts_safely "${EXTRA_OPTS}" "--builder-proposals")
fi

# If Import Operator setup mode is selected, use the --password-file flag to decrypt the private key
if [ "${SETUP_MODE}" = "Import Operator" ]; then
    PASSWORD_FILE_PATH="/root/.anchor/password.txt"
    PASSWORD_FILE="--password-file=${PASSWORD_FILE_PATH}"
fi

FLAGS="--network=${NETWORK} \
    --data-dir=${DATA_DIR} \
    --beacon-nodes=${BEACON_NODES} \
    --execution-rpc=${EXECUTION_RPC} \
    --execution-ws=${EXECUTION_WS} \
    --debug-level=${LOG_LEVEL} \
    --http \
    --http-address=0.0.0.0 \
    --http-port=${HTTP_PORT} \
    --unencrypted-http-transport \
    --metrics \
    --metrics-address=0.0.0.0 \
    --metrics-port=5164 \
    --port=${P2P_PORT} \
    $PASSWORD_FILE $EXTRA_OPTS"

echo "[INFO - entrypoint] Starting anchor with flags: $FLAGS"

# shellcheck disable=SC2086
exec anchor node $FLAGS
