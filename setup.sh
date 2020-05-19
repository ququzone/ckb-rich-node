#!/bin/bash
set -ex

[ -d /data/node ] || ckb init -c $NETWORK -C /data/node