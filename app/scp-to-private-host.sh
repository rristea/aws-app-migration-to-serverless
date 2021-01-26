#!/bin/bash

# Get directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Get the instance ID from the app-private-host stack
INSTANCE_ID=$(aws cloudformation describe-stacks --stack-name app-private-host --query "Stacks[0].Outputs[?OutputKey=='PrivateHost'].OutputValue" --output text)

#scp -i MyKeyPair.pem ${1} ec2-user@"${INSTANCE_ID}":/tmp

# scp through ssm
scp -i ${DIR}/tmp/app-private-host-keypair.pem \
    -o StrictHostKeyChecking=no \
    -o ProxyCommand="aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p" \
    ${1} ec2-user@"${INSTANCE_ID}":${2}
