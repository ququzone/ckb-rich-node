FROM ubuntu:bionic as builder
LABEL maintainer="Xueping Yang <xueping.yang@gmail.com>"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gcc \
        libc6-dev \
        wget \
        libssl-dev \
        git \
        pkg-config \
        libclang-dev clang; \
    rm -rf /var/lib/apt/lists/*

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUSTUP_VERSION=1.21.1 \
    RUSTUP_SHA256=ad1f8b5199b3b9e231472ed7aa08d2e5d1d539198a15c5b1e53c746aad81d27b \
    RUST_ARCH=x86_64-unknown-linux-gnu

RUN set -eux; \
    url="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${RUST_ARCH}/rustup-init"; \
    wget "$url"; \
    echo "${RUSTUP_SHA256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init

ENV RUST_VERSION=1.41.0

RUN set -eux; \
    ./rustup-init -y --no-modify-path --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version; \
    openssl version;

RUN git clone https://github.com/quake/ckb-indexer.git /ckb-indexer
RUN cd /ckb-indexer; \
    git checkout v0.1.0; \
    cargo build --release

FROM nginx:1.16
LABEL maintainer="Xueping Yang <xueping.yang@gmail.com>"

RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        software-properties-common

## CKB node
RUN wget https://github.com/nervosnetwork/ckb/releases/download/v0.30.2/ckb_v0.30.2_x86_64-unknown-linux-gnu.tar.gz -O /tmp/ckb_v0.30.2_x86_64-unknown-linux-gnu.tar.gz
RUN cd /tmp && tar xzf ckb_v0.30.2_x86_64-unknown-linux-gnu.tar.gz
RUN cp /tmp/ckb_v0.30.2_x86_64-unknown-linux-gnu/ckb /bin/ckb

## goreman
RUN mkdir /tmp/goreman && wget https://github.com/mattn/goreman/releases/download/v0.3.4/goreman_linux_amd64.zip -O /tmp/goreman/goreman_linux_amd64.zip
RUN cd /tmp/goreman && unzip goreman_linux_amd64.zip
RUN cp /tmp/goreman/goreman /bin/goreman

## dumb-init
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64.deb -O /tmp/dumb-init.deb
RUN dpkg -i /tmp/dumb-init.deb

## clean
RUN rm -rf /tmp/ckb_v0.30.2_x86_64-unknown-linux-gnu/ckb /tmp/goreman /tmp/dumb-init.deb
RUN apt-get -y remove wget unzip software-properties-common && apt-get -y autoremove && apt-get clean

## CKB network port
EXPOSE 8114
EXPOSE 8115
## indexer port
EXPOSE 8116
## nginx port
EXPOSE 8117

RUN mkdir /data
RUN mkdir /conf

COPY nginx.conf /conf/nginx.conf
COPY setup.sh /setup.sh
COPY Procfile /conf/Procfile

COPY --from=builder /ckb-indexer/target/release/ckb-indexer /usr/local/bin/ckb-indexer

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "-c", "/setup.sh && exec goreman -set-ports=false -exit-on-error -f /conf/Procfile start"]
