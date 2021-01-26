#!/bin/bash

# Get directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir "${DIR}/tmp"

# We need a key-pair to connect to the private EC2 instance. This can't be created through CloudFormation.
aws ec2 create-key-pair --key-name app-private-host-keypair | python3 -c "import sys, json; print(json.load(sys.stdin)['KeyMaterial'])" > "${DIR}/tmp/app-private-host-keypair.pem"

chmod 400 "${DIR}/tmp/app-private-host-keypair.pem"