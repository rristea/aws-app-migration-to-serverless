![Application](../resources/diagrams-app-serverless.png)

## Retriever

In order to migrate the Retriever application to a Serverless architecture, the following changes will be done:
* In order to run in Lambda, we must add soem new dependencies, and the `main()` method must be replaced with a `handle()` method:
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
