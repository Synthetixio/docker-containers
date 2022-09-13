FROM debian:bullseye-slim

# trunk-ignore(hadolint/DL3008)
RUN set -ex; \
    apt-get update; \
    apt-get install --no-install-recommends -y \
    bash \
    fluxbox \
    git \
    net-tools \
    novnc \
    supervisor \
    x11vnc \
    xterm \
    xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1920 \
    DISPLAY_HEIGHT=1080 \
    RUN_XTERM=yes \
    RUN_FLUXBOX=yes

COPY . /app
CMD ["/app/entrypoint.sh"]
EXPOSE 8080
