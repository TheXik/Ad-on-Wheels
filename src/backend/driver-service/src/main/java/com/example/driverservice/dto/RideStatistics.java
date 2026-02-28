package com.example.driverservice.dto;

public class RideStatistics {

    private Long totalRides;
    private Long completedRides;
    private Long verifiedRides;
    private Integer totalDurationSeconds;
    private Integer averageDurationSeconds;
    private Long activeRidesCount;
    
    // Distance and earnings
    private Double totalDistanceKm;
    private Double weeklyDistanceKm;
    private Double monthlyDistanceKm;
    private Double totalEarnings;
    private Double weeklyEarnings;
    private Double monthlyEarnings;
    private Double averageSpeedKmh;
    private Double rating;

    public RideStatistics() {
    }

    public RideStatistics(Long totalRides, Long completedRides, Long verifiedRides,
                         Integer totalDurationSeconds, Integer averageDurationSeconds,
                         Long activeRidesCount) {
        this.totalRides = totalRides;
        this.completedRides = completedRides;
        this.verifiedRides = verifiedRides;
        this.totalDurationSeconds = totalDurationSeconds;
        this.averageDurationSeconds = averageDurationSeconds;
        this.activeRidesCount = activeRidesCount;
    }
    
    public RideStatistics(Long totalRides, Long completedRides, Long verifiedRides,
                         Integer totalDurationSeconds, Integer averageDurationSeconds,
                         Long activeRidesCount, Double totalDistanceKm, Double weeklyDistanceKm,
                         Double monthlyDistanceKm, Double totalEarnings, Double weeklyEarnings,
                         Double monthlyEarnings, Double averageSpeedKmh, Double rating) {
        this.totalRides = totalRides;
        this.completedRides = completedRides;
        this.verifiedRides = verifiedRides;
        this.totalDurationSeconds = totalDurationSeconds;
        this.averageDurationSeconds = averageDurationSeconds;
        this.activeRidesCount = activeRidesCount;
        this.totalDistanceKm = totalDistanceKm;
        this.weeklyDistanceKm = weeklyDistanceKm;
        this.monthlyDistanceKm = monthlyDistanceKm;
        this.totalEarnings = totalEarnings;
        this.weeklyEarnings = weeklyEarnings;
        this.monthlyEarnings = monthlyEarnings;
        this.averageSpeedKmh = averageSpeedKmh;
        this.rating = rating;
    }

    // Getters and Setters
    public Long getTotalRides() {
        return totalRides;
    }

    public void setTotalRides(Long totalRides) {
        this.totalRides = totalRides;
    }

    public Long getCompletedRides() {
        return completedRides;
    }

    public void setCompletedRides(Long completedRides) {
        this.completedRides = completedRides;
    }

    public Long getVerifiedRides() {
        return verifiedRides;
    }

    public void setVerifiedRides(Long verifiedRides) {
        this.verifiedRides = verifiedRides;
    }

    public Integer getTotalDurationSeconds() {
        return totalDurationSeconds;
    }

    public void setTotalDurationSeconds(Integer totalDurationSeconds) {
        this.totalDurationSeconds = totalDurationSeconds;
    }

    public Integer getAverageDurationSeconds() {
        return averageDurationSeconds;
    }

    public void setAverageDurationSeconds(Integer averageDurationSeconds) {
        this.averageDurationSeconds = averageDurationSeconds;
    }

    public Long getActiveRidesCount() {
        return activeRidesCount;
    }

    public void setActiveRidesCount(Long activeRidesCount) {
        this.activeRidesCount = activeRidesCount;
    }
    
    public Double getTotalDistanceKm() {
        return totalDistanceKm;
    }

    public void setTotalDistanceKm(Double totalDistanceKm) {
        this.totalDistanceKm = totalDistanceKm;
    }

    public Double getWeeklyDistanceKm() {
        return weeklyDistanceKm;
    }

    public void setWeeklyDistanceKm(Double weeklyDistanceKm) {
        this.weeklyDistanceKm = weeklyDistanceKm;
    }

    public Double getMonthlyDistanceKm() {
        return monthlyDistanceKm;
    }

    public void setMonthlyDistanceKm(Double monthlyDistanceKm) {
        this.monthlyDistanceKm = monthlyDistanceKm;
    }

    public Double getTotalEarnings() {
        return totalEarnings;
    }

    public void setTotalEarnings(Double totalEarnings) {
        this.totalEarnings = totalEarnings;
    }

    public Double getWeeklyEarnings() {
        return weeklyEarnings;
    }

    public void setWeeklyEarnings(Double weeklyEarnings) {
        this.weeklyEarnings = weeklyEarnings;
    }

    public Double getMonthlyEarnings() {
        return monthlyEarnings;
    }

    public void setMonthlyEarnings(Double monthlyEarnings) {
        this.monthlyEarnings = monthlyEarnings;
    }

    public Double getAverageSpeedKmh() {
        return averageSpeedKmh;
    }

    public void setAverageSpeedKmh(Double averageSpeedKmh) {
        this.averageSpeedKmh = averageSpeedKmh;
    }

    public Double getRating() {
        return rating;
    }

    public void setRating(Double rating) {
        this.rating = rating;
    }
}
