import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FileHelper {
    private static final Logger logger = LoggerFactory.getLogger(FileHelper.class);

    public static void write(String data, String file) {
        try {
            File myObj = new File(file);
            if (myObj.createNewFile()) {
                logger.info("File created: " + myObj.getName());
            } else {
                logger.info("File already exists.");
            }

            new FileWriter(file, false).close();

            FileWriter myWriter = new FileWriter(file);
            myWriter.write(data);
            myWriter.close();
        } catch (IOException e) {
            logger.error("An error occurred.");
            e.printStackTrace();
        }
    }
}
