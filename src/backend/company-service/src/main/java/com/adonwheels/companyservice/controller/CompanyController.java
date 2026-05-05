package com.adonwheels.companyservice.controller;

import com.adonwheels.companyservice.model.Company;
import com.adonwheels.companyservice.service.CompanyService;
import com.adonwheels.dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;


@RestController
@RequestMapping("/companies")
public class CompanyController {
    private final CompanyService companyService;

    public CompanyController(CompanyService companyService) {
        this.companyService = companyService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Company>> getCompanyById(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, id);
        return ResponseEntity.ok(ApiResponse.success(companyService.findById(id)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Company>> createCompany(@Valid @RequestBody Company company) {
        Company saved = companyService.addCompany(company);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(saved));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCompany(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, id);
        companyService.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // Role gate (A3) lets COMPANY/ADMIN through; this pins the specific
    // company id so one company cannot read or delete another's profile.
    private void requireOwnership(Long callerId, String callerRole, Long pathOwnerId) {
        if ("ADMIN".equals(callerRole)) {
            return;
        }
        if (callerId == null || !callerId.equals(pathOwnerId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Caller is not authorized to act on this resource");
        }
    }
}