ARG UPSTREAM_VERSION

FROM sigp/anchor:${UPSTREAM_VERSION}

ARG NETWORK
ARG P2P_PORT
ARG STAKER_SCRIPTS_VERSION

ENV P2P_PORT=${P2P_PORT} \
    HTTP_PORT=5062 \
    STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ADD ${STAKER_SCRIPTS_URL}/dvt_lsd_tools.sh /etc/profile.d/

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    chmod +rx /etc/profile.d/dvt_lsd_tools.sh /usr/local/bin/entrypoint.sh

# Placed here to rebuild less layers
ENV NETWORK=${NETWORK}

ENTRYPOINT [ "entrypoint.sh" ]