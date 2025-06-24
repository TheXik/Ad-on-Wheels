package com.example.campaignservice.model;

public class Campaign {
    private Long id;
    private String title;
    private String description;
    private Long companyId;

    public Campaign() {}

    public Campaign(Long id, String title, String description, Long companyId) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.companyId = companyId;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Long getCompanyId() { return companyId; }
    public void setCompanyId(Long companyId) { this.companyId = companyId; }
} 