FROM rust:1.40 as builder

RUN git clone https://github.com/quake/ckb-indexer.git /ckb-indexer
# TODO add stable branch
RUN cd /ckb-indexer && cargo build --release
RUN cargo install --path .

FROM nginx:1.6
LABEL maintainer="Xueping Yang <xueping.yang@gmail.com>"

RUN apt-get update && apt-get install -y -no-install-recommends wget unzip software-properties-common

## CKB node
RUN wget https://github.com/nervosnetwork/ckb/releases/download/v0.30.2/ckb_v0.30.2_x86_64-unknown-linux-gnu.tar.gz -O /tmp/ckb_v0.30.2_x86_64-unknown-linux-gnu.tar.gz
RUN cd /tmp && tar xzf ckb_v0.30.2_x86_64-unknown-linux-gnu.tar.gz
RUN cp /tmp/ckb_v0.30.2_x86_64-unknown-linux-gnu/ckb /bin/ckb

## goreman
RUN mkdir /tmp/goreman && wget https://github.com/mattn/goreman/releases/download/v0.3.4/goreman_linux_amd64.zip -O /tmp/goreman/goreman_linux_amd64.zip
RUN cd /tmp/goreman && unzip goreman_linux_amd64.zip
RUN cp /tmp/goreman/goreman /bin/goreman

## dump-init
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64.deb -O /tmp/dumb-init.deb
RUN dpkg -i /tmp/dumb-init.deb

## clean
RUN rm -rf /tmp/ckb_v0.30.2_x86_64-unknown-linux-gnu/ckb /tmp/goreman /tmp/dumb-init.deb
RUN apt-get -y remove wget unzip software-properties-common && apt-get -y autoremove && apt-get clean

# CKB network port
EXPOSE 8114
EXPOSE 8115
# indexer port
EXPOSE 8116
# nginx port
EXPOSE 8117

RUN mkdir /data
RUN mkdir /indexer
RUN mkdir /conf

COPY nginx.conf /conf/nginx.conf
COPY setup.sh /conf/setup.sh
COPY Procfile /conf/Procfile

COPY --from=builder /usr/local/cargo/bin/ckb-indexer /usr/local/bin/ckb-indexer

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "-c", "/conf/setup.sh && exec goreman -set-ports=false -exit-on-error -f /data/conf/Procfile start"]
