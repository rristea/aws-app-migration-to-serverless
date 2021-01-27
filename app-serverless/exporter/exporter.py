import json
import logging
import mysql.connector

import exporterconfig as cfg

import boto3
import os

# The Lambda environment pre-configures a handler logging to stderr. If a handler is already configured,
# `.basicConfig` does not execute. Thus we set the level directly.
logging.getLogger().setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
ch = logging.StreamHandler()
ch.setFormatter(formatter)

def get_datetime(file):
    with open(file) as json_file:
        data = json.load(json_file)
        return data['datetime']

def execute_sql(sql, db):
    mycursor = db.cursor()
    logging.info("Inserting datetime into table")
    mycursor.execute(sql)
    db.commit()


def handle_request(event, context):
    logging.info("##### Starting exporter #####")

    logging.info("Download data file from S3")
    s3 = boto3.client('s3')
    s3.download_file(os.environ['BUCKET'],
                     os.path.basename(cfg.data_file),
                     cfg.data_file)

    datetime = get_datetime(cfg.data_file)
    logging.info(f"datetime is: {datetime}")

    logging.info(f"connecting to: {cfg.db_host}")
    creds = cfg.get_credentials()
    mydb = mysql.connector.connect(
        host=cfg.db_host,
        user=creds['username'],
        password=creds['password'],
        database=cfg.db_database
    )
    execute_sql(f"INSERT INTO exporter (data) VALUES (\"{datetime}\")", mydb)

    logging.info("##### Done #####")
