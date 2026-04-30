package com.adonwheels.driverservice.dto;

import com.adonwheels.dto.validation.NoHtml;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class OnboardingRequest {

    @NotBlank(message = "Vehicle make must not be blank")
    @NoHtml
    private String make;

    @NotBlank(message = "Vehicle model must not be blank")
    @NoHtml
    private String model;

    @NotBlank(message = "Vehicle year must not be blank")
    @Pattern(regexp = "^\\d{4}$", message = "Vehicle year must be a 4-digit number")
    private String year;

    @NotBlank(message = "License plate must not be blank")
    @Size(min = 2, max = 20, message = "License plate must be between 2 and 20 characters")
    @Pattern(regexp = "^[A-Z0-9 \\-]+$", message = "License plate may only contain uppercase letters, digits, spaces, and hyphens")
    private String licensePlate;

    private String color;

    private String vehicleImageUrl;

    @NotNull(message = "Monthly goal must not be null")
    @Min(value = 1, message = "Monthly goal must be at least 1 km")
    private Double monthlyGoalKm;

    public OnboardingRequest() {
    }

    public String getMake() {
        return make;
    }

    public void setMake(String make) {
        this.make = make;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getYear() {
        return year;
    }

    public void setYear(String year) {
        this.year = year;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public void setLicensePlate(String licensePlate) {
        this.licensePlate = licensePlate;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getVehicleImageUrl() {
        return vehicleImageUrl;
    }

    public void setVehicleImageUrl(String vehicleImageUrl) {
        this.vehicleImageUrl = vehicleImageUrl;
    }

    public Double getMonthlyGoalKm() {
        return monthlyGoalKm;
    }

    public void setMonthlyGoalKm(Double monthlyGoalKm) {
        this.monthlyGoalKm = monthlyGoalKm;
    }
}
