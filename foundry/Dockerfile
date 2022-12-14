FROM alpine:3.16 AS builder
WORKDIR /opt
RUN apk add clang lld curl build-base linux-headers git \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh \
    && chmod +x ./rustup.sh \
    && ./rustup.sh -y
RUN git clone https://github.com/foundry-rs/foundry.git \
    && cd foundry \
    && git reset --hard b554ab1fec09087fa3a35c6728968edca6debcf2
WORKDIR /opt/foundry
RUN source $HOME/.profile && cargo build --release \
    && strip /opt/foundry/target/release/forge \
    && strip /opt/foundry/target/release/cast \
    && strip /opt/foundry/target/release/anvil

FROM alpine:3.16 AS client
ENV GLIBC_KEY=https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
ENV GLIBC_KEY_FILE=/etc/apk/keys/sgerrand.rsa.pub
ENV GLIBC_RELEASE=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk

RUN apk add linux-headers gcompat git
RUN wget -q -O ${GLIBC_KEY_FILE} ${GLIBC_KEY} \
    && wget -O glibc.apk ${GLIBC_RELEASE} \
    && apk add glibc.apk --force
COPY --from=builder /opt/foundry/target/release/forge /usr/local/bin/forge
COPY --from=builder /opt/foundry/target/release/cast /usr/local/bin/cast
COPY --from=builder /opt/foundry/target/release/anvil /usr/local/bin/anvil
RUN adduser -Du 1000 foundry

ENV ANVIL_FORK_URL https://rpc.ankr.com/eth_goerli

EXPOSE 8545

ENTRYPOINT ["/bin/sh", "-c"]
