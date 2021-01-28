![Application](../resources/diagrams-app-serverless.png)

## Retriever

In order to migrate the Retriever application to a Serverless architecture, the following changes will be done:
* In order to run in Lambda, we must add some new dependencies, and the `main()` method must be replaced with a `handle()` method:
  * In `pom.xml`
  ```xml
    <dependency>
      <groupId>com.amazonaws</groupId>
      <artifactId>aws-lambda-java-core</artifactId>
    </dependency>
    <dependency>
      <groupId>com.amazonaws</groupId>
      <artifactId>aws-lambda-java-events</artifactId>
    </dependency>
  ```
  * In `Retriever.java`
  ```diff
  +  import com.amazonaws.services.lambda.runtime.Context;
  +  import java.util.Map;
  
    public class Retriever {
      private static final Logger logger = LoggerFactory.getLogger(Retriever.class);

  -    public static void main(String[] args) {
  +    public void handleRequest(Map<String,String> event, Context context) {
          logger.info("##### Starting retriever #####");
  ```
* For adding logs in CloudWatch, we need to add a new appender for log4j2 and change the config.
  * In `pom.xml`
  ```xml
    <dependency>
      <groupId>com.amazonaws</groupId>
      <artifactId>aws-lambda-java-log4j2</artifactId>
    </dependency>
  ```
  * In `log4j2.xml`
  ```diff
  <Configuration status="WARN">
      <Appenders>
  -        <File name="File" fileName="retriever.log">
  +        <Lambda name="Lambda">
              <PatternLayout>
                  <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>
              </PatternLayout>
  -        </File>
  +        </Lambda>
      </Appenders>
      <Loggers>
          <Root level="INFO">
  -            <AppenderRef ref="File"/>
  +            <AppenderRef ref="Lambda"/>
          </Root>
      </Loggers>
  </Configuration>
  ```
* For using DB credentials from SecretsManager, AWS has created a library that does this without requiring any code change. Only config changes needed.
  * In `pom.xml`
  ```xml
    <dependency>
      <groupId>com.amazonaws.secretsmanager</groupId>
      <artifactId>aws-secretsmanager-jdbc</artifactId>
    </dependency>
  ```
  * In `retriever.properties`
  ```diff
  -db.driver=com.mysql.cj.jdbc.Driver
  -db.url=jdbc:mysql://${DB_HOST}/app
  -db.user=admin
  -db.password=administrator
  +db.driver=com.amazonaws.secretsmanager.sql.AWSSecretsManagerMySQLDriver
  +db.url=jdbc-secretsmanager:mysql://${DB_HOST}/app
  +db.user=app-serverless-secret-private-db
  +db.password=placeholder
  ```
* For uploading the `time.json` file to S3, we first need to change the directory where teh file is generated. In Lambda, you only have write access to the `/tmp` folder. Then add the `aws-java-sdk-s3` dependency for SDKv1 (there is also a SDKv2 for Java but at the moment it has no support for uploading to encripted buckets). Finally we need to add the code for uploading the file, but there are a lot of examples in the AWS developer guide.
  * In `retriever.properties`
  ```diff
  -data.file=time.json
  +data.file=/tmp/time.json
  ```
  * In `pom.xml`
  ```xml
    <dependency>
      <groupId>com.amazonaws</groupId>
      <artifactId>aws-java-sdk-s3</artifactId>
      <version>1.11.880</version>
    </dependency>
  ```
  * For the code see `S3Upload.java`
* For packaging the application we'll use the `maven-shade-plugin` that will grate a fat JAR containing all the dependencies.
  ```diff
  -    <plugin>
  -      <groupId>org.apache.maven.plugins</groupId>
  -      <artifactId>maven-dependency-plugin</artifactId>
  -      [...]
  -    </plugin>
  -
  -   <plugin>
  -      <groupId>org.apache.maven.plugins</groupId>
  -      <artifactId>maven-jar-plugin</artifactId>
  -      [...]
  -    </plugin>
  +    <plugin>
  +      <groupId>org.apache.maven.plugins</groupId>
  +      <artifactId>maven-shade-plugin</artifactId>
  +      [...]
  +    </plugin>
  ```


## Exporter
In order to migrate the Retriever application to a Serverless architecture, the following changes will be done:
* In order to run in Lambda, we must import the `boto3` package, and we need to add a `handle()` method:
  * In `exporter.py`
  ```diff
  +import boto3
  [...]
  +def handle_request(event, context):
    logging.info("##### Starting exporter #####")
    [...]
  ```
* For adding logs in CloudWatch, we need to change the initialization of the logger. This is because the Lambda environment pre-configures a handler logging to stderr. If a handler is already configured, `.basicConfig` does not execute.
  * In `exporter.py`
  ```diff
  -logging.basicConfig(level=logging.DEBUG,
  -                    filename='exporter.log',
  -                    format='%(asctime)s %(levelname)s %(message)s')
  +logging.getLogger().setLevel(logging.DEBUG)
  +formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
  +ch = logging.StreamHandler()
  +ch.setFormatter(formatter)
  ```
* For downloading the file from S3 we will use the `boto3` package. We need to download it in the `/tmp` folder, as that's where the Lambda has write access.
  * In `exporterconfig.py`
  ```diff
  -data_file = "time.json"
  +data_file = "/tmp/time.json"
  ```
  * In `exporter.py`
  ```py
     s3 = boto3.client('s3')
     s3.download_file(os.environ['BUCKET'],
                      os.path.basename(cfg.data_file),
                      cfg.data_file)
  ```
* For using DB credentials from SecretsManager we will use again `boto3`.
  * In `exporterconfig.py`
  ```diff
  -db_user = "admin"
  -db_password = "administrator"
  +import boto3
  +from botocore.exceptions import ClientError
  +
  +def get_credentials():
  +  secret_name = 'app-serverless-secret-private-db'
  +
  +  session = boto3.session.Session()
  +  client = session.client(
  +      service_name='secretsmanager',
  +  )
  +
  +  try:
  +      get_secret_value_response = client.get_secret_value(
  +          SecretId=secret_name
  +      )
  +  except ClientError as e:
  +      [...]
  +  else:
  +      return json.loads(get_secret_value_response['SecretString'])
  ```
* For packaging the application we need to create a `.zip` with the scripts and all the dependencies.
  * Bash commands for creating the `.zip`
  ```bash
  mkdir tmp
  pip install --target ./tmp/ -r ./requirements.txt
  cd tmp
  zip -r exporter.zip ./*
  ```
