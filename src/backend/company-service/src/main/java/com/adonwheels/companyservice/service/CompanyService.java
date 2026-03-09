package com.adonwheels.companyservice.service;

import com.adonwheels.companyservice.model.Company;
import com.adonwheels.companyservice.repository.CompanyRepository;
import com.adonwheels.companyservice.exception.CompanyNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CompanyService {
    private final CompanyRepository repository;

    public CompanyService(CompanyRepository repository) {
        this.repository = repository;
    }

    public List<Company> getAllCompanies() {
        return repository.findAll();
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