#!/bin/bash

# Get directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Get DB host from the Stack output.
DB_HOST=$(aws cloudformation describe-stacks --stack-name app-private-db --query "Stacks[0].Outputs[?OutputKey=='PrivateServerlessDB'].OutputValue" --output text)

echo "Build Exporter"
# remove the tmp folder if it exists
if [ -d ${DIR}/exporter/tmp ]; then rm -Rf ${DIR}/exporter/tmp; fi
mkdir ${DIR}/exporter/tmp
cp ${DIR}/exporter/*.py ${DIR}/exporter/tmp/
sed -i -e "s/{{DB_HOST}}/${DB_HOST}/g" ${DIR}/exporter/tmp/exporterconfig.py
pip3 install --target ${DIR}/exporter/tmp/ -r ${DIR}/exporter/requirements.txt
cd ${DIR}/exporter/tmp/
zip -r exporter.zip ./*
cd -

echo "Update Lambda"
aws lambda update-function-code --function-name  app-serverless-lambda-exporter --zip-file fileb://${DIR}/exporter/tmp/exporter.zip
