FROM alpine:3.16

ARG GLIBC_VERSION=2.31-r0

# trunk-ignore(hadolint/DL3018)
RUN set -x \
 && apk add --no-cache -t .deps ca-certificates \
 && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && apk add --no-cache glibc-${GLIBC_VERSION}.apk \
 && rm glibc-${GLIBC_VERSION}.apk \
 && apk del --purge .deps

# trunk-ignore(hadolint/DL3018)
RUN set -x \
 && apk add --no-cache curl \
 && APKARCH="$(apk --print-arch)" \
 && case "$APKARCH" in \
      armhf)   NGROKARCH="arm" ;; \ 
      armv7)   NGROKARCH="arm" ;; \
      armel)   NGROKARCH="arm" ;; \
      x86)     NGROKARCH="386" ;; \
      x86_64)  NGROKARCH="amd64" ;; \
      aarch64)  NGROKARCH="amd64" ;; \
    esac \
 && wget -q -O ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-$NGROKARCH.tgz \
 && tar xvzf ngrok.tgz -C /bin \
 && rm -rf ngrok.tgz \
 && adduser -h /home/ngrok -D -u 6737 ngrok

COPY --chown=ngrok ngrok.yml /home/ngrok/.ngrok2/
COPY entrypoint.sh /

USER ngrok
ENV USER=ngrok

RUN ngrok --version

EXPOSE 4040

CMD ["/entrypoint.sh"]
