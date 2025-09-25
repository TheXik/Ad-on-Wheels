package com.example.companyservice.controller;

import com.example.companyservice.model.Company;
import com.example.companyservice.service.CompanyService;
import dto.ApiResponse;
import org.springframework.http.HttpStatus;
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
    public ResponseEntity<ApiResponse<List<Company>>> getAllCompanies() {

        List<Company> companies = companyService.GetAllCompanies();
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(companies));
    }

    // GET /companies/{id} - Get a company by ID
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Company>> getCompanyById(@PathVariable Long id) {

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(companyService.findById(id)));
    }

    // POST /companies - Create a new company
    @PostMapping
    public ResponseEntity<ApiResponse<Company>> createCompany(@RequestBody Company company) {
        Company saved = companyService.addCompany(company);
        return ResponseEntity //TODO Cross site scripting vulnerability sink
                .status(HttpStatus.OK)
                .body(ApiResponse.success(saved));
    }

    // DELETE /companies/{id} - Delete a company by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Object>> deleteCompany(@PathVariable Long id) {

        companyService.deleteById(id);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(null));
    }
} 