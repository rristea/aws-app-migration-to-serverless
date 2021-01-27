import os

import json

import boto3
from botocore.exceptions import ClientError


def get_credentials():
    secret_name = 'app-serverless-secret-private-db'

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("The requested secret " + secret_name + " was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("The request had invalid params:", e)

        raise
    else:
        return json.loads(get_secret_value_response['SecretString'])

db_host = "{{DB_HOST}}"
db_database = "app"

data_file = "/tmp/time.json"