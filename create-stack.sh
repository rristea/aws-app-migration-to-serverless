#!/bin/bash

TEMPLATE="${1}"
# Replace any '/' with '-' and remove the extension.
STACK_NAME=$(echo "${1/\//-}" | cut -f 1 -d '.')

aws cloudformation create-stack --stack-name "${STACK_NAME}" --template-body file://"${TEMPLATE}"  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation wait stack-create-complete --stack-name "${STACK_NAME}"
