## Deploying the application

This repo contains CloudFormation templates and scripts to deploy the application in AWS. The deployment has been tested from an AWS Cloud9 environment, on an Amazon Linux 2 instance. After creating the environment, you need to install the following:
* **Maven**: there is a Java component that will be built locally.
  ```bash
  sudo yum install maven -y
  ```
* **SessionManager Plugin**: The application has an EC2 instance in a private subnet. In order to ssh to it we will use SSM, in order to avoid creating a bastion host. But for this to work we need this plugin.
  ```bash
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
  sudo yum install -y session-manager-plugin.rpm
  ```

In order to deploy/delete the application, run the following scripts:
* `1-deploy-app.sh`: will deploy the CloudFormation stacks found in the folder `app/`, which contains a VPC with the application on an EC2 instance in a private subnet. See the `app/` folder for more details.
* `2-deploy-app-serverless.sh`: will deploy the CloudFormation stacks found in the folder `app-serverless/`. This depends on the previous stacks to be deployed, as there are dependencies on the same resources (ex VPC, Subnets, etc).
* `3-delete-app-serverless.sh`: This deletes the stacks that were deployed with `2-deploy-app-serverless.sh`
* `4-delete-app.sh`: This deletes the stacks that were deployed with `1-deploy-app.sh`

Here are some helper scripts for different operations:
* `create-stack.sh`: used to deploy any of the stacks (i.e. CloudFormation templates) individually.
* `update-stack.sh`: used to update any stack, once it was deployed; note that this only refers to changes in the CF template.
* `delete-stack.sh`: used to delte any stack.
* `app/ssh-to-private-host.sh`: can be ran to open a ssh connection to the EC2 instance that holds the application.
* `app/scp-to-private-host.sh`: can be ran to copy a file to the EC2 instance that holds the application.
* `app-serverless/lambda-retriever-update-function.s`: will build the serverless retriever and update the lambda-retriever with the new code.
* `app-serverless/lambda-exporter-update-function.s`: will build the serverless exporter and update the lambda-exporter with the new code.

## Intro

This repo contains two different AWS setups for an application that has two components: a Java component, and a Python component.
1. The first setup is a more "classic" approach, where the entire application is deployed on an EC2 instance.
2. The second setup is the same application in a Serverless architecture.

## The Application

The following diagram shows the application components:

![Application](resources/diagrams-application.png)

* The application is composed of two components:
  * Retriever: gets the current time from `worldtimeapi.org`, updates the `retriever` table, and exports the json response to a text file.
  * Exporter: reads the json file created by the Retriever and updates the `exporter` table.
* Since there is a dependency between these two components (the json file) there is a `run.sh` script that properly orchestrates the invocations.
* Both components output the application logs to their respective log files.
* Both components store DB credentials in config files. (**NOT GOOD!**)
  

## Initial Setup

The following diagram shows how the application components are initially deployed to AWS resources.

![Classic](resources/diagrams-classic.png)

* The whole application is deployed to a single EC2 instance.
* The DB is an RDS instance.

## Serverless Setup

The following diagram shows how the application can be deployed to a Serverless architecture.

![Serverless](resources/diagrams-serverless.png)

* The two components (Retriever and Exporter) are deployed to Lambda functions.
* The json file is uploaded to S3 (so that it can be shared between the 2 Lambdas).
* Application logs are sent to CloudWatch Logs.
* DB credentails are stored in SecretsManager.
* The two Lambdas are orchestrated with a StepFunction workflow.
* The DB remains the same RDS instance.
