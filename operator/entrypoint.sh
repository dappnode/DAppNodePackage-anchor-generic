#!/bin/bash

# shellcheck disable=SC1091 
# Path is relative to the Dockerfile
. /etc/profile

# These functions are in dvt_lsd_tools.sh: https://github.com/dappnode/staker-package-scripts/blob/main/scripts/dvt_lsd_tools.sh
EXECUTION_RPC=$(get_execution_rpc_api_url_from_global_env "$NETWORK")
EXECUTION_WS=$(get_execution_ws_url_from_global_env "$NETWORK")
BEACON_NODES=$(get_beacon_api_url_from_global_env "$NETWORK")

mkdir -p /root/.anchor

PASSWORD_FILE_PATH="/root/.anchor/password.txt"

# If Import Operator, save the EXISTING_PASSWORD to the password.txt,
# Later when Anchor is starting it will use --password-file flag to decrypt the private key
if [ "${SETUP_MODE}" = "Import Operator" ]; then
    KEY_FILE_PATH="/root/.anchor/encrypted_private_key.json"

    echo "[INFO - entrypoint] Using existing password to import operator"
    echo "[DEBUG] EXISTING_PASSWORD is set: $([ -n "$EXISTING_PASSWORD" ] && echo 'YES' || echo 'NO')"
    echo "[DEBUG] encrypted_private_key.json exists: $([ -f /root/.anchor/encrypted_private_key.json ] && echo 'YES' || echo 'NO')"
    echo "[DEBUG] password.txt exists: $([ -f "$PASSWORD_FILE_PATH" ] && echo 'YES' || echo 'NO')"
    echo "$EXISTING_PASSWORD" > "$PASSWORD_FILE_PATH"
    
fi

# If New Operator, generate a new public-private key pair
if [ "${SETUP_MODE}" = "New Operator" ]; then
    
    # Check if the key file exists
    if [ -f "$ENCRYPTED_PRIVATE_KEY" ]; then
        echo "[INFO - entrypoint] Key already exists, skipping key generation"
    else
    # If key file does not exist, generate a new key pair
        echo "[INFO - entrypoint] Generating new public-private key pair"
        # Use expect to handle interactive password prompts during key generation
        # Use --data-dir to overwrite the default directory to the directory used in this DAppNode package
        expect << EOF
spawn anchor keygen --encrypt --data-dir /root/.anchor
expect "Enter password for keyfile:"
send "$NEW_PASSWORD\r"
expect "Re-enter password to confirm:"
send "$NEW_PASSWORD\r"
expect eof
EOF

       # Save NEW_PASSWORD to the password file for use later
       echo "$NEW_PASSWORD" > "$PASSWORD_FILE_PATH"
    fi
fi

PASSWORD_FILE="--password-file=${PASSWORD_FILE_PATH}"

if [ -f "$KEY_FILE_PATH" ]; then
KEY_FILE="--key-file=${KEY_FILE_PATH}"
else 
KEY_FILE=""
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
    $KEY_FILE $PASSWORD_FILE $EXTRA_OPTS"

echo "[INFO - entrypoint] Starting anchor with flags: $FLAGS"

# shellcheck disable=SC2086
exec anchor node $FLAGS
