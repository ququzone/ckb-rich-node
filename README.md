ckb-rich-node
=============

> A ckb node with indexer

## Usage

### Local build

```bash
docker build -t ckb-rich-node .
docker run --name ckb-rich-node-mainnet -d -e NETWORK=mainnet -p 8117:8117 -v "$PWD/data":/data ckb-rich-node
docker run --name ckb-rich-node-testnet -d -e NETWORK=testnet -p 8117:8117 -v "$PWD/data":/data ckb-rich-node
```

### Pull from DockerHub

```
docker pull ququzone/ckb-rich-node
docker run --name ckb-rich-node-mainnet -d -e NETWORK=mainnet -p 8117:8117 -v "$PWD/data":/data ququzone/ckb-rich-node
docker run --name ckb-rich-node-testnet -d -e NETWORK=testnet -p 8117:8117 -v "$PWD/data":/data ququzone/ckb-rich-node
```

### CKB node RPC

```
echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_blockchain_info",
    "params": []
}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8117/rpc
```

More RPC method can be refer [ckb rpc docs](https://github.com/nervosnetwork/ckb/blob/master/rpc/README.md)

### CKB indexer RPC

```
echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_cells",
    "params": [
        {
            "script": {
                "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                "hash_type": "type",
                "args": "0x8211f1b938a107cd53b6302cc752a6fc3965638d"
            },
            "script_type": "lock"
        },
        "asc",
        "0x64"
    ]
}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8117/indexer
```

More RPC method can be refer [ckb-indexer](https://github.com/quake/ckb-indexer)
