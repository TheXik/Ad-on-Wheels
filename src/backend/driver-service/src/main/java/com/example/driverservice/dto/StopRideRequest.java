package com.example.driverservice.dto;

public class StopRideRequest {

    private String endLocation; // Optional
    private Double distanceKm; // Distance traveled in km
    private Double averageSpeedKmh; // Average speed in km/h

    public StopRideRequest() {
    }

    public StopRideRequest(String endLocation) {
        this.endLocation = endLocation;
    }
    
    public StopRideRequest(String endLocation, Double distanceKm, Double averageSpeedKmh) {
        this.endLocation = endLocation;
        this.distanceKm = distanceKm;
        this.averageSpeedKmh = averageSpeedKmh;
    }

    // Getters and Setters
    public String getEndLocation() {
        return endLocation;
    }

    public void setEndLocation(String endLocation) {
        this.endLocation = endLocation;
    }
    
    public Double getDistanceKm() {
        return distanceKm;
    }
    
    public void setDistanceKm(Double distanceKm) {
        this.distanceKm = distanceKm;
    }
    
    public Double getAverageSpeedKmh() {
        return averageSpeedKmh;
    }
    
    public void setAverageSpeedKmh(Double averageSpeedKmh) {
        this.averageSpeedKmh = averageSpeedKmh;
    }
}
