ARG PYTHON_VERSION

FROM python:${PYTHON_VERSION}-slim-bookworm AS build_stage

LABEL org.opencontainers.image.authors="charahiro <charahiro.tan@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/Charahiro-tan/steamcmd-python"
LABEL org.opencontainers.image.description="A Docker image that includes Python with steamcmd."
LABEL org.opencontainers.image.licenses=MIT

ARG USER=steam

ARG PUID=1000
ARG HOME_DIR="/home/${USER}"
ARG STEAMCMD_DIR="${HOME_DIR}/steamcmd"

ENV USER=${USER} \
    HOME=${HOME_DIR} \
    STEAMCMD_DIR=${STEAMCMD_DIR}

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        lib32stdc++6 \
        lib32gcc-s1 \
        ca-certificates \
        nano \
        curl \
        locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && useradd -u "${PUID}" -m "${USER}" \
    && su "${USER}" -c \
        "mkdir -p \"${STEAMCMD_DIR}\" \
        && curl -fsSL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar xvzf - -C "${STEAMCMD_DIR}" \
        && \"./${STEAMCMD_DIR}/steamcmd.sh\" +quit \
        && ln -s \"${STEAMCMD_DIR}/linux32/steamclient.so\" \"${STEAMCMD_DIR}/steamservice.so\" \
        && mkdir -p \"${HOME_DIR}/.steam/sdk32\" \
        && ln -s \"${STEAMCMD_DIR}/linux32/steamclient.so\" \"${HOME_DIR}/.steam/sdk32/steamclient.so\" \
        && ln -s \"${STEAMCMD_DIR}/linux32/steamcmd\" \"${STEAMCMD_DIR}/linux32/steam\" \
        && mkdir -p \"${HOME_DIR}/.steam/sdk64\" \
        && ln -s \"${STEAMCMD_DIR}/linux64/steamclient.so\" \"${HOME_DIR}/.steam/sdk64/steamclient.so\" \
        && ln -s \"${STEAMCMD_DIR}/linux64/steamcmd\" \"${STEAMCMD_DIR}/linux64/steam\" \
        && ln -s \"${STEAMCMD_DIR}/steamcmd.sh\" \"${STEAMCMD_DIR}/steam.sh\"" \
    && ln -s "${STEAMCMD_DIR}/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so" \
    && rm -rf /var/lib/apt/lists/*

FROM build_stage AS bookworm-root
WORKDIR ${STEAMCMD_DIR}

FROM bookworm-root AS bookworm-user
USER ${USER}