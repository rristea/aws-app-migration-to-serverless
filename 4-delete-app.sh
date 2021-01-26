#!/bin/bash

echo "Delete DB"
./delete-stack.sh app/private-db
echo "Delete Host"
./delete-stack.sh app/private-host
echo "Delete Network"
./delete-stack.sh app/network
echo "Delete key-pair"
./app/private-host-keypair-delete.sh
