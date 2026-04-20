#!/bin/sh

# shellcheck disable=SC1091 
# Path is relative to the Dockerfile
. /etc/profile

# These functions are in dvt_lsd_tools.sh: https://github.com/dappnode/staker-package-scripts/blob/main/scripts/dvt_lsd_tools.sh
EXECUTION_RPC=$(get_execution_rpc_api_url_from_global_env "$NETWORK")
EXECUTION_WS=$(get_execution_ws_url_from_global_env "$NETWORK")
BEACON_NODES=$(get_beacon_api_url_from_global_env "$NETWORK")

PASSWORD_FILE_PATH="/root/keys/password.txt"
KEY_FILE_PATH="/root/keys/encrypted_private_key.json"
sleep 5

# If Import Operator, save the EXISTING_PASSWORD to the password.txt,
# Later when Anchor is starting it will use --password-file flag to decrypt the private key
if [ "${SETUP_MODE}" = "Import Operator" ]; then
    echo "[INFO - entrypoint] Using existing password to import operator"
    if [ ! -f "$KEY_FILE_PATH" ]; then
        echo "[DEBUG] encrypted_private_key.json doesn't exist, restarting"
        exit 1
    fi
    if [ -z "$EXISTING_PASSWORD" ]; then
        echo "[ERROR - entrypoint] EXISTING_PASSWORD is required in Import Operator mode"
        exit 1
    fi
    echo "$EXISTING_PASSWORD" > "$PASSWORD_FILE_PATH"
fi

# New install or update flow.
# Keep existing key+password pairing on updates; only require NEW_PASSWORD for first-time key generation.
if [ "${SETUP_MODE}" = "New Operator / Update" ] || [ "${SETUP_MODE}" = "New Operator" ]; then
    if [ -f "$KEY_FILE_PATH" ]; then
        echo "[INFO - entrypoint] Key already exists, preserving existing password and skipping key generation"
    else
        if [ -z "$NEW_PASSWORD" ]; then
            echo "[ERROR - entrypoint] NEW_PASSWORD is required when generating a new operator key"
            exit 1
        fi
        echo "$NEW_PASSWORD" > "$PASSWORD_FILE_PATH"
        echo "[INFO - entrypoint] Generating new public-private key pair"
        anchor keygen --encrypt --password-file="$PASSWORD_FILE_PATH" --data-dir /root/keys
    fi
fi

if [ -f "$KEY_FILE_PATH" ]; then
    KEY_FILE="--key-file=${KEY_FILE_PATH}"
else 
    KEY_FILE=""
fi

FLAGS="--network=${NETWORK} \
    --data-dir=/root/.anchor \
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
    --password-file=${PASSWORD_FILE_PATH} \
    $KEY_FILE $EXTRA_OPTS"

echo "[INFO - entrypoint] Starting anchor with flags: $FLAGS"

# shellcheck disable=SC2086
exec anchor node $FLAGS
