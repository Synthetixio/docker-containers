FROM nginx:1.23.3-alpine-slim

COPY nginx.conf /etc/nginx/nginx.conf

# trunk-ignore(hadolint/DL3018)
RUN apk add --no-cache \
    wget \
    && echo "Finished installing packages"

RUN mkdir -p /etc/nginx/bots.d && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/globalblacklist.conf -O /etc/nginx/conf.d/globalblacklist.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/blockbots.conf -O /etc/nginx/bots.d/blockbots.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/ddos.conf -O /etc/nginx/bots.d/ddos.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/whitelist-ips.conf -O /etc/nginx/bots.d/whitelist-ips.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/whitelist-domains.conf -O /etc/nginx/bots.d/whitelist-domains.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/blacklist-user-agents.conf -O /etc/nginx/bots.d/blacklist-user-agents.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/custom-bad-referrers.conf -O /etc/nginx/bots.d/custom-bad-referrers.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/blacklist-ips.conf -O /etc/nginx/bots.d/blacklist-ips.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/bad-referrer-words.conf -O /etc/nginx/bots.d/bad-referrer-words.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/botblocker-nginx-settings.conf -O /etc/nginx/conf.d/botblocker-nginx-settings.conf

# remove duplicated IPs from globalblacklist.conf
RUN sed -i 's/^\t*138.199.57.151\t*1;$/#\t138.199.57.151\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf && \
    sed -i 's/^\t*143.244.38.129\t*1;$/#\t143.244.38.129\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf && \
    sed -i 's/^\t*195.181.163.194\t*1;$/#\t195.181.163.194\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf && \
    sed -i 's/^\t*5.188.120.15\t*1;$/#\t5.188.120.15\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf && \
    sed -i 's/^\t*89.187.173.66\t*1;$/#\t89.187.173.66\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf

# copy nginx blocker update script into daily cron
COPY update_blocker.sh /etc/periodic/daily/update_blocker

# make sure script is executable
RUN chmod a+x /etc/periodic/daily/update_blocker

# start crond to update blocker
# trunk-ignore(hadolint/DL3059)
RUN crond -b

### WAF
ARG LIB_SODIUM_VER=1.0.18-RELEASE

RUN apk add --no-cache git

WORKDIR /usr/local/src
RUN git clone -b lts https://github.com/ADD-SP/ngx_waf.git

SHELL ["/bin/sh", "-o", "pipefail", "-c"]
RUN set -xe \
    &&  apk update \
    &&  apk add --no-cache uthash-dev \
            gcc \
            libc-dev \
            make \
            openssl-dev \
            pcre-dev \
            zlib-dev \
            linux-headers \
            curl \
            gnupg \
            libxslt-dev \
            gd-dev \
            python3 \
            py3-pip \
            flex \
            bison \
    &&  pip3 install lastversion
RUN set -xe \
    &&  (cd ngx_waf && git clone https://github.com/libinjection/libinjection.git inc/libinjection) \
    &&  (cd ngx_waf && make parser) \
    &&  git clone https://github.com/troydhanson/uthash.git \
    &&  export LIB_UTHASH=/usr/local/src/uthash \
    &&  git clone https://github.com/jedisct1/libsodium.git --branch ${LIB_SODIUM_VER} libsodium-src \
    &&  cd libsodium-src \
    &&  ./configure --prefix=/usr/local/src/libsodium --with-pic \
    &&  make -j$(nproc) && make check -j$(nproc) && make install \
    &&  export LIB_SODIUM=/usr/local/src/libsodium \
    &&  cd .. \
    # &&  lastversion --download="openssl.tar.gz" --at=github openssl \
    # &&  mkdir openssl && tar -zxf "openssl.tar.gz" -C openssl --strip-components=1 \
    &&  lastversion --download="nginx.tar.gz" --major mainline https://nginx.org \
    &&  mkdir nginx && tar -zxf "nginx.tar.gz" -C nginx --strip-components=1 \
    &&  cd nginx \
    &&  ./configure \
        --with-debug \
        # --with-openssl=/usr/local/src/openssl \
        --add-dynamic-module=/usr/local/src/ngx_waf \
        --with-compat \
        --with-cc-opt='-fstack-protector-strong' \
    && make modules -j$(nproc)
# WORKDIR /usr/local/src/nginx
# RUN sed -i 's/^\(CFLAGS.*\)/\1 -fstack-protector-strong -Wno-sign-compare/' objs/Makefile
# RUN make modules -j$(nproc)
