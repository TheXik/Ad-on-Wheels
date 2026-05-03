package com.adonwheels.companyservice.service;

import com.adonwheels.companyservice.model.Company;
import com.adonwheels.companyservice.repository.CompanyRepository;
import com.adonwheels.companyservice.exception.CompanyNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
public class CompanyService {
    private final CompanyRepository repository;

    public CompanyService(CompanyRepository repository) {
        this.repository = repository;
    }

    public Company findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new CompanyNotFoundException(id));
    }

    @Transactional
    public Company addCompany(Company company) {
        return repository.save(company);
    }

    @Transactional
    public void deleteById(Long id) {
        repository.deleteById(id);
    }
} 