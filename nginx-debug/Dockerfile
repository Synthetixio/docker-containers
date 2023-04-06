ARG NGINX_VER=1.23.4

FROM nginx:${NGINX_VER}-alpine as base

ARG NGX_WAF_VERSION=current
ARG CJSON_VERSION=v1.7.15
ARG UTHASH_VERSION=v2.3.0
ARG LIB_SODIUM_VERSION=1.0.18-RELEASE
ARG MODSEC_VERSION=v3.0.8
ARG MODSEC_NGINX_CONNECTOR_VERSION=v1.0.3
ARG NGINX_GEOIP2_MODULE_VERSION=3.4
ARG GEO_DB_RELEASE=2023-04
ARG OWASP_TAG=v3.3.4
ARG BROTLI_VERSION=master
ARG HEADERS_MORE_VERSION=master

WORKDIR /opt

# trunk-ignore(hadolint/DL3018)
RUN apk add --no-cache --virtual dependencies \
    autoconf \
    automake \
    byacc \
    curl-dev \
    cmake \
    cargo \
    flex \
    g++ \
    gcc \
    geoip-dev \
    gd-dev \
    git \
    go \
    gnupg \
    libcurl \
    libc-dev \
    libmaxminddb \
    libmaxminddb-dev \
    libstdc++ \
    libtool \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    lmdb-dev \
    make \
    openssl-dev \
    pcre-dev \
    perl \
    patch \
    rust \
    yajl-dev \
    zlib-dev

# install ngx_waf
RUN git clone --depth=1 https://github.com/ADD-SP/ngx_waf --branch ${NGX_WAF_VERSION} \
    && git clone --depth=1 https://github.com/DaveGamble/cJSON.git --branch ${CJSON_VERSION} ngx_waf/lib/cjson \
    && git clone --depth=1 https://github.com/troydhanson/uthash.git --branch ${UTHASH_VERSION} ngx_waf/lib/uthash \
    && cp -r /opt/ngx_waf/assets /etc/nginx/waf_assets

# install libsodium
RUN git clone --depth=1 https://github.com/jedisct1/libsodium.git --branch ${LIB_SODIUM_VERSION} libsodium \
    &&  cd libsodium \
    &&  ./configure --prefix=/usr/local/libsodium --with-pic \
    &&  make -j$(nproc) \
    &&  make check -j$(nproc) \
    &&  make install

# install ModSecurity
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity.git --branch ${MODSEC_VERSION} && \
    git -C /opt/ModSecurity submodule update --init --recursive && \
    (cd "/opt/ModSecurity" && \
    ./build.sh && \
    ./configure --with-lmdb && \
    make -j$(nproc) && \
    make install \
    ) && \
    rm -fr /opt/ModSecurity \
    /usr/local/modsecurity/lib/libmodsecurity.a \
    /usr/local/modsecurity/lib/libmodsecurity.la

# install modsec nginx connector, geoip, owasp rules, and nginx with geoip databases
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git --branch ${MODSEC_NGINX_CONNECTOR_VERSION} && \
    git clone --depth 1 https://github.com/leev/ngx_http_geoip2_module.git --branch ${NGINX_GEOIP2_MODULE_VERSION} && \
    git clone --depth 1 https://github.com/coreruleset/coreruleset.git --branch ${OWASP_TAG} /usr/local/owasp-modsecurity-crs && \
    wget -O - https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar -xz && \
    mkdir -p /etc/nginx/geoip && \
    wget -O - https://download.db-ip.com/free/dbip-city-lite-${GEO_DB_RELEASE}.mmdb.gz | gzip -d > /etc/nginx/geoip/dbip-city-lite.mmdb && \
    wget -O - https://download.db-ip.com/free/dbip-country-lite-${GEO_DB_RELEASE}.mmdb.gz | gzip -d > /etc/nginx/geoip/dbip-country-lite.mmdb

# install brotli
RUN git clone --depth=1 https://github.com/google/ngx_brotli --branch ${BROTLI_VERSION}

# install headers-more
RUN git clone --depth=1 https://github.com/openresty/headers-more-nginx-module --branch ${HEADERS_MORE_VERSION}

ENV LIB_SODIUM=/usr/local/libsodium
ENV LIB_MODSECURITY=/usr/local/modsecurity

# install nginx modules
RUN (cd "/opt/nginx-$NGINX_VERSION" && \
    ./configure --with-compat \
    --with-debug \
    --add-dynamic-module=../ngx_waf \
    --add-dynamic-module=../ModSecurity-nginx \
    --add-dynamic-module=../ngx_http_geoip2_module \
    --add-dynamic-module=../ngx_brotli \
    --add-dynamic-module=../headers-more-nginx-module \
    --with-cc-opt='-fstack-protector-strong' && \
    make modules \
    ) && \
    cp /opt/nginx-$NGINX_VERSION/objs/ngx_http_modsecurity_module.so \
    /opt/nginx-$NGINX_VERSION/objs/ngx_http_geoip2_module.so \
    /opt/nginx-$NGINX_VERSION/objs/ngx_http_waf_module.so \
    /opt/nginx-$NGINX_VERSION/objs/ngx_http_brotli_filter_module.so \
    /opt/nginx-$NGINX_VERSION/objs/ngx_http_brotli_static_module.so \
    /opt/nginx-$NGINX_VERSION/objs/ngx_http_headers_more_filter_module.so \
    /usr/lib/nginx/modules/ && \
    rm -fr /opt/* && \
    apk del dependencies

# setup bad bot blocker
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

FROM nginx:${NGINX_VER}-alpine as production

# copy nginx, waf assets, owasp-modsecurity-crs, and modsecurity from the build image
COPY --from=base /etc/nginx/ /etc/nginx/
COPY --from=base /usr/local/modsecurity /usr/local/modsecurity
COPY --from=base /usr/local/owasp-modsecurity-crs /usr/local/owasp-modsecurity-crs
COPY --from=base /usr/lib/nginx/modules/ /usr/lib/nginx/modules/

# copy local config files into the image
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf/modsec/ /etc/nginx/modsec/
COPY conf/owasp/ /usr/local/owasp-modsecurity-crs/

RUN apk add --no-cache \
    curl-dev \
    libmaxminddb-dev \
    libstdc++ \
    libxml2-dev \
    lmdb-dev \
    pcre \
    tzdata \
    yajl

# copy nginx blocker update script into daily cron
COPY update_blocker.sh /etc/periodic/daily/update_blocker

# make sure script is executable
RUN chmod a+x /etc/periodic/daily/update_blocker

# start crond to update blocker
# trunk-ignore(hadolint/DL3059)
RUN crond -b

WORKDIR /etc/nginx

EXPOSE 80 443
