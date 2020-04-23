ckb-rich-node
=============

> A ckb node with indexer

## Usage

```bash
docker build -t ckb-rich-node .
docker run --name ckb-rich-node -d -p 8117:8117 -v /data:/data -d ckb-rich-node
```
