import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CurrentTime {
    private static final Logger logger = LoggerFactory.getLogger(CurrentTime.class);

    private static final String USER_AGENT = "Mozilla/5.0";

    public static String get() throws Exception {

        String url = "https://worldtimeapi.org/api/timezone/Europe/Bucharest";

        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();

        //Request header
        con.setRequestProperty("User-Agent", USER_AGENT);

        int responseCode = con.getResponseCode();
        logger.info("Sending 'GET' request to URL : {}", url);
        logger.info("Response Code : {}", responseCode);

        BufferedReader in = new BufferedReader(
                new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuffer response = new StringBuffer();

        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        String responseBody = response.toString();

        logger.info("Response body: {}", responseBody);

        return responseBody;
    }
}