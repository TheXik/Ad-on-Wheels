package com.example.companyservice.controller;

import com.example.companyservice.model.Company;
import com.example.companyservice.service.CompanyService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/companies")
public class CompanyController {
    private final CompanyService companyService;

    public CompanyController(CompanyService companyService) {
        this.companyService = companyService;
    }

    // GET /companies - List all companies
    @GetMapping
    public List<Company> getAllCompanies() {
        return companyService.findAll();
    }

    // GET /companies/{id} - Get a company by ID
    @GetMapping("/{id}")
    public ResponseEntity<Company> getCompanyById(@PathVariable Long id) {
        return ResponseEntity.ok(companyService.findById(id));
    }

    // POST /companies - Create a new company
    @PostMapping
    public ResponseEntity<Company> createCompany(@RequestBody Company company) {
        Company saved = companyService.save(company);
        return ResponseEntity.ok(saved);
    }

    // DELETE /companies/{id} - Delete a company by ID
    @DeleteMapping("/{id}")
    public void deleteCompany(@PathVariable Long id) {
        companyService.deleteById(id);
    }
} 