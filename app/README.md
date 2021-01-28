![Application](../resources/diagrams-app.png)

## Retriever

Java application that does the following:
1. Makes an HTTP GET to `https://worldtimeapi.org/api/timezone/Europe/Bucharest` to retrieve the current time in a JSON format:
  ```
  {"abbreviation":"EET","client_ip":"52.70.86.225","datetime":"2021-01-28T07:53:07.930142+02:00","day_of_week":4,"day_of_year":28,"dst":false,"dst_from":null,"dst_offset":0,"dst_until":null,"raw_offset":7200,"timezone":"Europe/Bucharest","unixtime":1611813187,"utc_datetime":"2021-01-28T05:53:07.930142+00:00","utc_offset":"+02:00","week_number":4}
  ```
2. Extracts the `"datetime"` from the JSON and inserts it in the DB table `retriever`.
3. Writs the original JSON response to a file `time.json`.

The java application is structured as follows:
* Maven is used as build tool.
* Application config is done through a `retriever.properties` file:
  ```
  db.driver=com.mysql.cj.jdbc.Driver
  db.url=jdbc:mysql://${DB_HOST}/app
  db.user=admin
  db.password=administrator

  data.file=time.json
  ```
* For DB connectivity and operations:
  * In `pom.xml`:
  ```xml
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
    </dependency>
  ```
  * In `DBConnection.java`
  ```java
    Class.forName(driver);
    conn = DriverManager.getConnection(url, user, password);
    stmt = conn.createStatement();
    stmt.executeUpdate(sql);
  ```
* For logging it is used log4j2:
  * In `pom.xml`:
  ```xml
    <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-api</artifactId>
    </dependency>
    <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-core</artifactId>
    </dependency>
    <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-slf4j-impl</artifactId>
    </dependency>
  ```
  * In `log4j2.xml`
  ```xml
  <Configuration status="WARN">
      <Appenders>
          <File name="File" fileName="retriever.log">
              <PatternLayout>
                  <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>
              </PatternLayout>
          </File>
      </Appenders>
      <Loggers>
          <Root level="INFO">
              <AppenderRef ref="File"/>
          </Root>
      </Loggers>
  </Configuration>
  ```
  * In `Retriever.java`:
  ```
  import org.slf4j.Logger;
  import org.slf4j.LoggerFactory;

  public class Retriever {
      private static final Logger logger = LoggerFactory.getLogger(Retriever.class);

      public static void main(String[] args) {
          logger.info("##### Starting retriever #####");
          //...
      }
  }
  ```
* For packaging it is used `maven-jar-plugin` (to create the jar file) and `maven-dependency-plugin` to add it's dependen in a `lib` folder that will be deployed along with the jar.
  * In `pom.xml`
  ```xml
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-dependency-plugin</artifactId>
        [...]
      </plugin>

     <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        [...]
      </plugin>
  ```
