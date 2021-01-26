#!/bin/bash

# If the script receives a param, then it will be considered a command to be ran through ssh.
COMMAND="${1}"

# Get directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Get the instance ID from the app-private-host stack
INSTANCE_ID=$(aws cloudformation describe-stacks --stack-name app-private-host --query "Stacks[0].Outputs[?OutputKey=='PrivateHost'].OutputValue" --output text)

# ssh through ssm
ssh -i ${DIR}/tmp/app-private-host-keypair.pem \
    -o StrictHostKeyChecking=no \
    -o ProxyCommand="aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p" \
    ec2-user@"${INSTANCE_ID}" ${COMMAND}
