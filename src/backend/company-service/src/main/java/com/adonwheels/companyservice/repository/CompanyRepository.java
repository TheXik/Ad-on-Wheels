package com.adonwheels.companyservice.repository;

import com.adonwheels.companyservice.model.Company;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CompanyRepository extends JpaRepository<Company, Long> {
} 