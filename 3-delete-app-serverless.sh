#!/bin/bash

echo "Delete Workflow StepFunction"
./delete-stack.sh app-serverless/workflow-stepfunction.yml
echo "Delete Exporter Lambda"
./delete-stack.sh app-serverless/lambda-exporter.yml
echo "Delete Retriever Lambda"
./delete-stack.sh app-serverless/lambda-retriever.yml
echo "Delete DB secret"
./delete-stack.sh app-serverless/secret-private-db.yml
echo "Remove all objects from S3 bucket"
aws s3 rm s3://app-serverless-s3-bucket-s3bucket --recursive
echo "Delete S3 bucket"
./delete-stack.sh app-serverless/s3-bucket.yml
