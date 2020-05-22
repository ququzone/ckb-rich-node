#!/bin/bash
set -ex

if [ ! -f /bin/ckb ]; then
  wget https://github.com/nervosnetwork/ckb/releases/download/v$CKB_VERSION/ckb_v$CKB_VERSION_x86_64-unknown-linux-gnu.tar.gz -O /tmp/ckb_v$CKB_VERSION_x86_64-unknown-linux-gnu.tar.gz
  cd /tmp && tar xzf ckb_v$CKB_VERSION_x86_64-unknown-linux-gnu.tar.gz
  mv /tmp/ckb_v$CKB_VERSION_x86_64-unknown-linux-gnu/ckb /bin/ckb
  rm -rf /tmp/ckb_v$CKB_VERSION_x86_64-unknown-linux-gnu* 
fi

[ -d /data/node ] || ckb init -c $NETWORK -C /data/node