#!/bin/sh

ROOT_DIR=$(cd "$(dirname "$0")"; pwd)
cd $ROOT_DIR

lines=$((`wc -l node_modules/caboose/bin/caboose | awk '{print $1}'` - 1))

echo "#!$ROOT_DIR/node/bin/node" > node_modules/caboose/bin/caboose2
tail -n$lines node_modules/caboose/bin/caboose >> node_modules/caboose/bin/caboose2
chmod +x node_modules/caboose/bin/caboose2

node_modules/caboose/bin/caboose2 server
