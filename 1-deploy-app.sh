#!/bin/bash

echo "Deploy network"
./create-stack.sh app/network.yml
echo "Create key-pair"
./app/private-host-keypair-create.sh
echo "Deploy host"
./create-stack.sh app/private-host.yml
echo "Deploy DB"
./create-stack.sh app/private-db.yml

echo "Init DB"
# Copy the DB init script on the Host
./app/scp-to-private-host.sh app/init-db.sql /tmp
# Get DB host from the Stack output.
DB_HOST=$(aws cloudformation describe-stacks --stack-name app-private-db --query "Stacks[0].Outputs[?OutputKey=='PrivateServerlessDB'].OutputValue" --output text)
# Run the DB init script on the Host.
./app/ssh-to-private-host.sh "mysql -h ${DB_HOST} -u admin -padministrator < /tmp/init-db.sql"

echo "Create app directory on host"
./app/ssh-to-private-host.sh "mkdir ~/app"

echo "Build Retriever"
# Build the Retriever, and replace the host DB in the properties files.
mvn package resources:resources -DDB_HOST="${DB_HOST}" -f app/retriever/pom.xml

echo "Setup Retriever on Host"
tar -czvf app/tmp/retriever.tar.gz -C app/retriever/target/ retriever-1.0-SNAPSHOT.jar lib/
./app/scp-to-private-host.sh app/tmp/retriever.tar.gz /tmp
./app/ssh-to-private-host.sh "mv /tmp/retriever.tar.gz ~/app/ && tar -xzvf ~/app/retriever.tar.gz -C ~/app/ && rm -f ~/app/retriever.tar.gz"

echo "Build Exporter"
# We are actually only moving the py files into tmp/ folder, and replacing the DB URL in the config file
mkdir ./app/exporter/tmp
cp ./app/exporter/*.py ./app/exporter/tmp/
sed -i -e "s/{{DB_HOST}}/${DB_HOST}/g" ./app/exporter/tmp/exporterconfig.py

echo "Setup Exporter on Host"
# Copy the py files
tar -czvf app/tmp/exporter.tar.gz -C app/exporter/tmp/ exporter.py exporterconfig.py
./app/scp-to-private-host.sh app/tmp/exporter.tar.gz /tmp
./app/ssh-to-private-host.sh "mv /tmp/exporter.tar.gz ~/app/ && tar -xzvf ~/app/exporter.tar.gz -C ~/app/ && rm -f ~/app/exporter.tar.gz"
# Install the dependencies
./app/scp-to-private-host.sh app/exporter/requirements.txt /tmp
./app/ssh-to-private-host.sh "sudo pip3 install -r /tmp/requirements.txt"

echo "Copy run script on Host"
./app/scp-to-private-host.sh app/run.sh /tmp
./app/ssh-to-private-host.sh "mv /tmp/run.sh ~/app/"
