package com.example.driverservice.dto;

public class RideStatistics {

    private Long totalRides;
    private Long completedRides;
    private Long verifiedRides;
    private Integer totalDurationSeconds;
    private Integer averageDurationSeconds;
    private Long activeRidesCount;

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
}
