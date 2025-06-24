package com.example.companyservice.repository;

import com.example.companyservice.model.Company;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CompanyRepository extends JpaRepository<Company, Long> {
} 