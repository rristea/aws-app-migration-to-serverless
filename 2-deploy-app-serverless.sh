#!/bin/bash

# echo "Deploy S3 bucket"
# ./create-stack.sh app-serverless/s3-bucket.yml

# Get DB host from the Stack output.
DB_HOST=$(aws cloudformation describe-stacks --stack-name app-private-db --query "Stacks[0].Outputs[?OutputKey=='PrivateServerlessDB'].OutputValue" --output text)

# echo "Build Retriever"
# # Build the Retriever, and replace the host DB in the properties files.
# mvn package resources:resources -DDB_HOST="${DB_HOST}" -f app-serverless/retriever/pom.xml

# echo "Copy Retriever to S3"
# aws s3 cp app-serverless/retriever/target/retriever-1.0-SNAPSHOT.jar s3://app-serverless-s3-bucket-s3bucket/ --sse AES256

# echo "Deploy Retriever Lambda"
# ./create-stack.sh app-serverless/lambda-retriever.yml

# echo "Deploy DB secret"
# ./create-stack.sh app-serverless/secret-private-db.yml

# echo "Build Exporter"
# mkdir ./app-serverless/exporter/tmp
# cp ./app-serverless/exporter/*.py ./app-serverless/exporter/tmp/
# sed -i -e "s/{{DB_HOST}}/${DB_HOST}/g" ./app-serverless/exporter/tmp/exporterconfig.py
# pip3 install --target ./app-serverless/exporter/tmp/ -r ./app-serverless/exporter/requirements.txt
# cd ./app-serverless/exporter/tmp/
# zip -r exporter.zip ./*
# cd -

# echo "Copy Exporter to S3"
# aws s3 cp app-serverless/exporter/tmp/exporter.zip s3://app-serverless-s3-bucket-s3bucket/ --sse AES256

echo "Deploy Exporter Lambda"
./create-stack.sh app-serverless/lambda-exporter.yml
