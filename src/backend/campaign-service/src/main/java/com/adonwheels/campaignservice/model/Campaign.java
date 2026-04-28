package com.adonwheels.campaignservice.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
public class Campaign {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String name;

    @NotBlank
    @Column(length = 2000)
    private String description;

    @NotNull
    private Long companyId;

    @NotNull
    private LocalDate startDate;

    @NotNull
    private LocalDate endDate;

    @NotNull
    @Positive
    private BigDecimal budget;

    @NotNull
    @Positive
    private Integer maxDrivers;

    @NotNull
    @Positive
    @Column(precision = 10, scale = 4)
    private BigDecimal ratePerKm;

    private Long estimatedReach;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CampaignStatus status = CampaignStatus.RECRUITING;

    @ElementCollection
    @CollectionTable(name = "campaign_image_keys", joinColumns = @JoinColumn(name = "campaign_id"))
    @Column(name = "image_key")
    @OrderColumn(name = "sort_order")
    private List<String> imageKeys = new ArrayList<>();

    @Transient
    private List<String> imageUrls;

    public Campaign() {
    }

    public Campaign(String name, String description, Long companyId,
                    LocalDate startDate, LocalDate endDate, BigDecimal budget,
                    Integer maxDrivers, Long estimatedReach, CampaignStatus status) {
        this.name = name;
        this.description = description;
        this.companyId = companyId;
        this.startDate = startDate;
        this.endDate = endDate;
        this.budget = budget;
        this.maxDrivers = maxDrivers;
        this.estimatedReach = estimatedReach;
        this.status = status;
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

    public CampaignStatus getStatus() { return status; }
    public void setStatus(CampaignStatus status) { this.status = status; }

    public List<String> getImageKeys() { return imageKeys; }
    public void setImageKeys(List<String> imageKeys) { this.imageKeys = imageKeys; }

    public List<String> getImageUrls() { return imageUrls; }
    public void setImageUrls(List<String> imageUrls) { this.imageUrls = imageUrls; }
} 