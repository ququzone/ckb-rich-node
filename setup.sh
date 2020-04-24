#!/bin/bash
set -ex

[ -d /data/node ] || ckb init -c mainnet -C /data/node