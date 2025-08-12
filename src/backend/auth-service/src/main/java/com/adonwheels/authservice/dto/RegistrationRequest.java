package com.adonwheels.authservice.dto;

import com.adonwheels.authservice.model.Role;

public class RegistrationRequest {
    private String email;
    private String password;
    private String name; // Name for the profile
    private Role role;   // Use the Role enum

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
