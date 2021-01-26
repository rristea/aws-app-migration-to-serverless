import json
import logging
import mysql.connector

import exporterconfig as cfg

logging.basicConfig(level=logging.DEBUG,
                    filename='exporter.log',
                    format='%(asctime)s %(levelname)s %(message)s')

def get_datetime(file):
    with open(file) as json_file:
        data = json.load(json_file)
        return data['datetime']

def execute_sql(sql, db):
    mycursor = db.cursor()
    logging.info("Inserting datetime into table")
    mycursor.execute(sql)
    db.commit()


logging.info("##### Starting exporter #####")

datetime = get_datetime(cfg.data_file)
logging.info(f"datetime is: {datetime}")

logging.info(f"connecting to: {cfg.db_host}")
mydb = mysql.connector.connect(
    host=cfg.db_host,
    user=cfg.db_user,
    password=cfg.db_passwod,
    database=cfg.db_database
)
execute_sql(f"INSERT INTO exporter (data) VALUES (\"{datetime}\")", mydb)

logging.info("##### Done #####")
