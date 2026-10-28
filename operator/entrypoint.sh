#!/bin/bash

# shellcheck disable=SC1091 
# Path is relative to the Dockerfile
. /etc/profile

# These functions are in dvt_lsd_tools.sh: https://github.com/dappnode/staker-package-scripts/blob/main/scripts/dvt_lsd_tools.sh
EXECUTION_RPC=$(get_execution_rpc_api_url_from_global_env "$NETWORK")
EXECUTION_WS=$(get_execution_ws_url_from_global_env "$NETWORK")
BEACON_NODES=$(get_beacon_api_url_from_global_env "$NETWORK")

PASSWORD_FILE_PATH="/root/keys/private_key_password"
KEY_FILE_PATH="/root/keys/encrypted_private_key.json"
sleep 1

post_pubkey_to_dappmanager() {
  # The public key is embedded in the encrypted private key file
  PUBLIC_KEY=$(jq -r '.pubkey // .pubKey // empty' "$KEY_FILE_PATH")

  if [ -z "$PUBLIC_KEY" ]; then
    echo "[ERROR - entrypoint] Public key not found in ${KEY_FILE_PATH}, skipping Dappmanager post"
    return 1
  fi

  curl --connect-timeout 5 \
    --max-time 10 \
    --silent \
    --retry 5 \
    --retry-delay 0 \
    --retry-max-time 40 \
    -X POST "http://dappmanager.dappnode/data-send?key=OperatorPublicKey&data=${PUBLIC_KEY}" || \
    {
      echo "[ERROR - entrypoint] Failed to post public key to Dappmanager"
    }

  echo "[INFO - entrypoint] Use this public key to register your node on the SSV network:"
  echo "PUBLIC_KEY=${PUBLIC_KEY}"
}

# Packages installed before 0.1.9 (Anchor 1.4.1) stored the password in password.txt
# rename it so that it is backward-compatible
if [ -f /root/keys/password.txt ]; then
    echo "[INFO - entrypoint] Renaming password.txt to private_key_password"
    mv -f /root/keys/password.txt "$PASSWORD_FILE_PATH"
fi

# In Import Operator, save the EXISTING_PASSWORD to the password file at first import
# Later when Anchor is starting it will use --password-file flag to decrypt the private key
if [ "${SETUP_MODE}" = "Import Operator" ]; then

    # Only write password to password file on first time setup when password file does not exist
    # this means that subsequent changes in EXISTING_PASSWORD will not be effective
    # this also means that users must provide the correct password during the first time setup
    if [ ! -f "$PASSWORD_FILE_PATH" ]; then
        echo "$EXISTING_PASSWORD" > "$PASSWORD_FILE_PATH"
    fi

    echo "[INFO - entrypoint] Using uploaded key to import operator"
    if [ ! -f "$KEY_FILE_PATH" ]; then
        echo "[DEBUG] encrypted_private_key.json doesn't exist, restarting"
        exit 1
    fi
fi

# If New Operator, generate a new public-private key pair during the first time setup
if [ "${SETUP_MODE}" = "New Operator" ]; then
    # Check if the key file exists
    if [ -f "$KEY_FILE_PATH" ]; then
        echo "[INFO - entrypoint] Key already exists, skipping key generation"
    else
        # Only write password and generate key when creating a new key pair
        # same case as Import Operator, subsequent changes in NEW_PASSWORD will not be effective
        echo "$NEW_PASSWORD" > "$PASSWORD_FILE_PATH"
        echo "[INFO - entrypoint] Generating new public-private key pair"
        anchor keygen --encrypt --password-file="$PASSWORD_FILE_PATH" --data-dir /root/keys
        # keygen also writes public_key.txt, remove it to keep it out of the backup files
        rm -f /root/keys/public_key.txt
    fi
fi

if [ -f "$KEY_FILE_PATH" ]; then
    KEY_FILE="--key-file=${KEY_FILE_PATH}"
else 
    KEY_FILE=""
fi

post_pubkey_to_dappmanager

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
    --quic-port=${QUIC_PORT} \
    --enr-udp-port=${P2P_PORT} \
    --enr-tcp-port=${P2P_PORT} \
    --enr-quic-port=${QUIC_PORT} \
    --password-file=${PASSWORD_FILE_PATH} \
    $KEY_FILE $EXTRA_OPTS"

echo "[INFO - entrypoint] Starting anchor with flags: $FLAGS"

# shellcheck disable=SC2086
exec anchor node $FLAGS
