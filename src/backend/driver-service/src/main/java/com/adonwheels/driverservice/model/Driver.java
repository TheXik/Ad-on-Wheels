package com.adonwheels.driverservice.model;

import com.adonwheels.dto.validation.NoHtml;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;

@Entity
@Table(name = "drivers")
public class Driver {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    @NotBlank
    @NoHtml
    private String name;

    @Column(nullable = false)
    @Email
    @NotBlank
    private String email;

    @Column(nullable = true)
    @NoHtml
    private String vehicleMake;

    @Column(nullable = true)
    @NoHtml
    private String vehicleModel;
    
    @Column(nullable = true)
    private String vehicleYear;
    
    @Column(nullable = true)
    private String vehiclePlate;
    
    @Column(nullable = true)
    private String vehicleColor;

    @Column(nullable = true)
    private String vehicleImageUrl;

    @Column(nullable = true)
    private Boolean vehicleVerified;

    @Column(nullable = true)
    private Double rating;
    
    @Column(nullable = true)
    private LocalDateTime lastVerificationDate;

    @Column(nullable = true)
    private Double monthlyGoalKm;

    @Column(nullable = true)
    private Boolean onboardingCompleted;

    @Column(nullable = true)
    private LocalDateTime memberSince;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getVehicleMake() {
        return vehicleMake;
    }

    public void setVehicleMake(String vehicleMake) {
        this.vehicleMake = vehicleMake;
    }

    public String getVehicleModel() {
        return vehicleModel;
    }

    public void setVehicleModel(String vehicleModel) {
        this.vehicleModel = vehicleModel;
    }

    public String getVehicleYear() {
        return vehicleYear;
    }

    public void setVehicleYear(String vehicleYear) {
        this.vehicleYear = vehicleYear;
    }

    public String getVehiclePlate() {
        return vehiclePlate;
    }

    public void setVehiclePlate(String vehiclePlate) {
        this.vehiclePlate = vehiclePlate;
    }

    public String getVehicleColor() {
        return vehicleColor;
    }

    public void setVehicleColor(String vehicleColor) {
        this.vehicleColor = vehicleColor;
    }

    public String getVehicleImageUrl() {
        return vehicleImageUrl;
    }

    public void setVehicleImageUrl(String vehicleImageUrl) {
        this.vehicleImageUrl = vehicleImageUrl;
    }

    public Boolean getVehicleVerified() {
        return vehicleVerified;
    }

    public void setVehicleVerified(Boolean vehicleVerified) {
        this.vehicleVerified = vehicleVerified;
    }

    public Double getRating() {
        return rating;
    }

    public void setRating(Double rating) {
        this.rating = rating;
    }

    public LocalDateTime getLastVerificationDate() {
        return lastVerificationDate;
    }

    public void setLastVerificationDate(LocalDateTime lastVerificationDate) {
        this.lastVerificationDate = lastVerificationDate;
    }

    public LocalDateTime getMemberSince() {
        return memberSince;
    }

    public void setMemberSince(LocalDateTime memberSince) {
        this.memberSince = memberSince;
    }

    public Double getMonthlyGoalKm() {
        return monthlyGoalKm;
    }

    public void setMonthlyGoalKm(Double monthlyGoalKm) {
        this.monthlyGoalKm = monthlyGoalKm;
    }

    public Boolean getOnboardingCompleted() {
        return onboardingCompleted;
    }

    public void setOnboardingCompleted(Boolean onboardingCompleted) {
        this.onboardingCompleted = onboardingCompleted;
    }
} 