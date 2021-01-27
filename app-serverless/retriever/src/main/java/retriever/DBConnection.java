import java.sql.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DBConnection {
    private static final Logger logger = LoggerFactory.getLogger(DBConnection.class);

    private String url;
    private String user;
    private String password;

    private Connection conn = null;

    public DBConnection(String driver, String dburl, String dbuser, String dbpassword) {
        url = dburl;
        user = dbuser;
        password = dbpassword;

        try {
            Class.forName(driver);
        } catch (Exception e) {
            //Handle errors for Class.forName
            logger.error("Error loading driver");
        }
    }

    public void execute(String sql) {
       Statement stmt = null;
       try {
          logger.info("Connecting to database {}", url);
          conn = DriverManager.getConnection(url, user, password);

          logger.info("Creating statement...");
          stmt = conn.createStatement();

          int rowsAffected = stmt.executeUpdate(sql);
          logger.info("Affected rows: " + rowsAffected);

          stmt.close();
          conn.close();
       } catch (SQLException se) {
          //Handle errors for JDBC
          logger.error("JDBC error");
       } catch (Exception e) {
          //Handle errors for Class.forName
          logger.error("Error");
       } finally {
          //finally block used to close resources
          try {
             if (stmt!=null)
                stmt.close();
          } catch(SQLException se2) {
          }// nothing we can do

          try {
             if (conn!=null)
                conn.close();
          } catch (SQLException se) {
             logger.error("JDBC error");
          }//end finally try
       }//end try
    }
}//end DBConnection