package com.example.companyservice.service;

import com.example.companyservice.model.Company;
import com.example.companyservice.repository.CompanyRepository;
import com.example.companyservice.exception.CompanyNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CompanyService {
    private final CompanyRepository repository;

    public CompanyService(CompanyRepository repository) {
        this.repository = repository;
    }

    public List<Company> GetAllCompanies() {
        return repository.findAll();
    }

    public Company findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new CompanyNotFoundException(id));
    }

    public Company addCompany(Company company) {
        return repository.save(company);
    }

    public void deleteById(Long id) {
        repository.deleteById(id);
    }
} 