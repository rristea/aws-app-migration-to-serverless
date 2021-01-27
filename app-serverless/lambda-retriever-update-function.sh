#!/bin/bash

# Get directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Get DB host from the Stack output.
DB_HOST=$(aws cloudformation describe-stacks --stack-name app-private-db --query "Stacks[0].Outputs[?OutputKey=='PrivateServerlessDB'].OutputValue" --output text)

echo "Build Retriever"
# Build the Retriever, and replace the host DB in the properties files.
mvn package resources:resources -DDB_HOST="${DB_HOST}" -f ${DIR}/retriever/pom.xml

echo "Update Lambda"
aws lambda update-function-code --function-name  app-serverless-lambda-retriever --zip-file fileb://${DIR}/retriever/target/retriever-1.0-SNAPSHOT.jar
