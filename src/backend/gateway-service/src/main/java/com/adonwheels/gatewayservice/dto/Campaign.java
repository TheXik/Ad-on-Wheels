package com.adonwheels.gatewayservice.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class Campaign {
    private Long id;
    private String name;
    private String description;
    private Long companyId;
    private LocalDate startDate;
    private LocalDate endDate;
    private BigDecimal budget;
    private Integer maxDrivers;
    private BigDecimal ratePerKm;
    private Long estimatedReach;
    private String status;
    private List<String> imageUrls;

    public Campaign() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Long getCompanyId() { return companyId; }
    public void setCompanyId(Long companyId) { this.companyId = companyId; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public BigDecimal getBudget() { return budget; }
    public void setBudget(BigDecimal budget) { this.budget = budget; }

    public Integer getMaxDrivers() { return maxDrivers; }
    public void setMaxDrivers(Integer maxDrivers) { this.maxDrivers = maxDrivers; }

    public BigDecimal getRatePerKm() { return ratePerKm; }
    public void setRatePerKm(BigDecimal ratePerKm) { this.ratePerKm = ratePerKm; }

    public Long getEstimatedReach() { return estimatedReach; }
    public void setEstimatedReach(Long estimatedReach) { this.estimatedReach = estimatedReach; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public List<String> getImageUrls() { return imageUrls; }
    public void setImageUrls(List<String> imageUrls) { this.imageUrls = imageUrls; }
} 