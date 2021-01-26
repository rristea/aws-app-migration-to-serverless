#!/bin/bash

# Get directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

rm -rf "${DIR}/tmp"

aws ec2 delete-key-pair --key-name app-private-host-keypair

