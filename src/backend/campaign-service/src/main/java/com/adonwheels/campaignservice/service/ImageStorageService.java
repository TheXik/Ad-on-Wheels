package com.adonwheels.campaignservice.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class ImageStorageService {

    private static final int MAX_IMAGES_PER_CAMPAIGN = 5;
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;

    private final S3Client s3Client;

    @Value("${app.minio.bucket}")
    private String bucket;

    public ImageStorageService(S3Client s3Client) {
        this.s3Client = s3Client;
    }

    public List<String> upload(Long campaignId, List<MultipartFile> files, int existingCount) {
        if (existingCount + files.size() > MAX_IMAGES_PER_CAMPAIGN) {
            throw new IllegalArgumentException(
                    "Maximum " + MAX_IMAGES_PER_CAMPAIGN + " images per campaign. " +
                    "Currently " + existingCount + ", trying to add " + files.size() + ".");
        }

        List<String> keys = new ArrayList<>();
        for (MultipartFile file : files) {
            validateFile(file);
            String key = campaignId + "/" + UUID.randomUUID() + getExtension(file.getOriginalFilename());
            try {
                s3Client.putObject(
                        PutObjectRequest.builder()
                                .bucket(bucket)
                                .key(key)
                                .contentType(file.getContentType())
                                .build(),
                        RequestBody.fromBytes(file.getBytes()));
                keys.add(key);
            } catch (IOException e) {
                throw new RuntimeException("Failed to upload image", e);
            }
        }
        return keys;
    }

    public byte[] download(String key) {
        return s3Client.getObjectAsBytes(
                GetObjectRequest.builder()
                        .bucket(bucket)
                        .key(key)
                        .build()
        ).asByteArray();
    }

    public String getContentType(String key) {
        return s3Client.headObject(b -> b.bucket(bucket).key(key)).contentType();
    }

    public void delete(String key) {
        s3Client.deleteObject(DeleteObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .build());
    }

    public String buildImageUrl(String key) {
        return "/api/campaigns/images/" + key;
    }

    private void validateFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("File exceeds maximum size of 5MB");
        }
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Only image files are allowed");
        }
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return ".jpg";
        return filename.substring(filename.lastIndexOf('.'));
    }
}
