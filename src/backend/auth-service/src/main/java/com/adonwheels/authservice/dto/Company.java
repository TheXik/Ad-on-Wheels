package com.adonwheels.authservice.dto;

//TODO figure out better way of transporting inside the profile REQUESTS

public class Company {

    private Long id;


    private String name;

    private String email;

    public Company() {
    }

    public Company(String name, String email) {
        this.name = name;
        this.email = email;
    }

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
}