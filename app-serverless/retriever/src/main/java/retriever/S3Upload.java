import java.io.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.amazonaws.SdkClientException;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.*;

public class S3Upload {

    private static final Logger LOGGER = LoggerFactory.getLogger(S3Upload.class);

    private final static String BUCKET_VAR = "BUCKET";

    public final static void upload(String file) {
        String s3Bucket = System.getenv(BUCKET_VAR);
        LOGGER.info("Uploading to bucket {}", s3Bucket);

        AmazonS3 s3Client = AmazonS3ClientBuilder.standard().build();

        uploadObjectWithSSEEncryption(file, s3Client, s3Bucket, new File(file).getName());
    }

    private final static void uploadObjectWithSSEEncryption(String objectPath,
                                                            AmazonS3 s3Client,
                                                            String bucketName,
                                                            String keyName) {
        try {
            byte[] objectBytes = readBytesFromFile(objectPath);

            // Specify server-side encryption.
            ObjectMetadata objectMetadata = new ObjectMetadata();
            objectMetadata.setContentLength(objectBytes.length);
            objectMetadata.setSSEAlgorithm(ObjectMetadata.AES_256_SERVER_SIDE_ENCRYPTION);
            PutObjectRequest putRequest = new PutObjectRequest(bucketName,
                    keyName,
                    new ByteArrayInputStream(objectBytes),
                    objectMetadata);

            s3Client.putObject(putRequest);
        } catch (SdkClientException | FileNotFoundException e) {
            LOGGER.warn("Error uploading {}. Reason: {}", objectPath, e.getMessage());
        }
    }

    private static byte[] readBytesFromFile(String filePath) throws FileNotFoundException {

        FileInputStream fileInputStream = null;
        byte[] bytesArray = null;

        try {
            File file = new File(filePath);
            bytesArray = new byte[(int) file.length()];

            fileInputStream = new FileInputStream(file);
            fileInputStream.read(bytesArray);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (fileInputStream != null) {
                try {
                    fileInputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return bytesArray;
    }

}
