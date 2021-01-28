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
            <configuration>
              <outputDirectory>${project.build.directory}/lib</outputDirectory>
            </configuration>
        [...]
      </plugin>

     <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        [...]
              <classpathPrefix>lib/</classpathPrefix>
        [...]
      </plugin>
  ```
  
  
## Exporter
  
Python application that does the following:
1. Retrieves the time data from `time.json`.
2. Extracts the `"datetime"` from the JSON and inserts it in the DB table `exporter`.

The python application is structured as follows:
* Application config is done through a `exporterconfig.py` module:
```py
db_host = "{{DB_HOST}}"
db_user = "admin"
db_password = "administrator"
db_database = "app"

data_file = "time.json"
```
* For DB connectivity and operations we use `mysql-connector-python` package.
  * In `requirements.txt`
  ```
  mysql-connector-python
  ```
  * In `exporter.py`
  ```py
  import mysql.connector
  import exporterconfig as cfg
  [...]
  db = mysql.connector.connect(
      host=cfg.db_host,
      user=cfg.db_user,
      password=cfg.db_password,
      database=cfg.db_database
  )
  mycursor = db.cursor()
  mycursor.execute(sql)
  db.commit()
  ```
* For logging we use the `logging` package.
  * In `exporter.py`
  ```py
  import logging
  logging.basicConfig(level=logging.DEBUG,
                      filename='exporter.log',
                      format='%(asctime)s %(levelname)s %(message)s')
  [...]
  logging.info("##### Starting exporter #####")
  ```
* For packaging there is nothing special done. The scripts are deployed on the host and the dependencies installed with `pip install -r requirements.txt`.
