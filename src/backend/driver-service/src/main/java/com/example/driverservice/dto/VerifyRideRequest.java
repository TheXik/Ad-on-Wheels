package com.example.driverservice.dto;

import jakarta.validation.constraints.NotBlank;

public class VerifyRideRequest {

    @NotBlank(message = "QR code data is required")
    private String qrCodeData;

    public VerifyRideRequest() {
    }

    public VerifyRideRequest(String qrCodeData) {
        this.qrCodeData = qrCodeData;
    }

    // Getters and Setters
    public String getQrCodeData() {
        return qrCodeData;
    }

    public void setQrCodeData(String qrCodeData) {
        this.qrCodeData = qrCodeData;
    }
}
