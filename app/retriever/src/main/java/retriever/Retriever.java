import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Retriever {
    private static final Logger logger = LoggerFactory.getLogger(Retriever.class);

    public static void main(String[] args) {
        String currentTime = null;
        try {
            currentTime = CurrentTime.get();
        } catch (Exception e) {
            // TODO
        }

        try (InputStream input = Retriever.class.getClassLoader().getResourceAsStream("retriever.properties")) {
            Properties prop = new Properties();
            prop.load(input);

            DBConnection sql = new DBConnection(prop.getProperty("db.driver"),
                                                prop.getProperty("db.url"),
                                                prop.getProperty("db.user"),
                                                prop.getProperty("db.password"));

            JSONObject jObject = new JSONObject(currentTime);
            String datetimeObject = jObject.getString("datetime");
            logger.info("datetime is: {}", datetimeObject);

            String insert = "insert into retriever (data) values (\"" + datetimeObject + "\");";
            sql.execute(insert);

            FileHelper.write(currentTime);
        } catch (IOException ex) {
            logger.error("Error reading properties file.");
        }

        logger.info("Goodbye!");
    }//end main
}//end Retriever