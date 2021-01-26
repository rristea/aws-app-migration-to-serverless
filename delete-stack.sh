#!/bin/bash

TEMPLATE="${1}"
# Replace any '/' with '-' and remove the extension.
STACK_NAME=$(echo "${1/\//-}" | cut -f 1 -d '.')

aws cloudformation delete-stack --stack-name "${STACK_NAME}"

aws cloudformation wait stack-delete-complete --stack-name "${STACK_NAME}"
