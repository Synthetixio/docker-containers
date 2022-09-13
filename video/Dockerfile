FROM jrottenberg/ffmpeg:4.4.2-ubuntu2004

# trunk-ignore(hadolint/SC2028)
RUN echo "deb http://archive.ubuntu.com/ubuntu focal main universe\n" > /etc/apt/sources.list \
    && echo "deb http://archive.ubuntu.com/ubuntu focal-updates main universe\n" >> /etc/apt/sources.list \
    && echo "deb http://security.ubuntu.com/ubuntu focal-security main universe\n" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

# trunk-ignore(hadolint/DL3008)
RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
    supervisor x11-xserver-utils python3-pip \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

COPY supervisord.conf /etc
COPY entrypoint.sh /opt/bin/
COPY video.sh /opt/bin/
COPY video_ready.py /opt/bin/
WORKDIR /opt/bin
RUN pip install --no-cache-dir psutil==5.9.2

# trunk-ignore(hadolint/DL3059)
RUN mkdir -p /var/run/supervisor /var/log/supervisor /videos

ENTRYPOINT ["/opt/bin/entrypoint.sh"]
CMD ["/opt/bin/entrypoint.sh"]

ENV DISPLAY_NUM 0
ENV DISPLAY_CONTAINER_NAME display
ENV SE_SCREEN_WIDTH 1920
ENV SE_SCREEN_HEIGHT 1080
ENV SE_FRAME_RATE 15
ENV SE_CODEC libx264
ENV SE_PRESET "-preset ultrafast"
ENV FILE_NAME video.mp4

EXPOSE 9000
