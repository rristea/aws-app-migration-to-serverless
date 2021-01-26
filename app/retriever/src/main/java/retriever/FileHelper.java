import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class FileHelper {

    private static String FILE = "time.json";

    public static void write(String data) {
        try {
            File myObj = new File(FILE);
            if (myObj.createNewFile()) {
                System.out.println("File created: " + myObj.getName());
            } else {
                System.out.println("File already exists.");
            }

            new FileWriter(FILE, false).close();

            FileWriter myWriter = new FileWriter(FILE);
            myWriter.write(data);
            myWriter.close();
        } catch (IOException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }
    }
}
