package com.example.driverservice.service;

import com.example.driverservice.model.Driver;
import com.example.driverservice.exception.DriverNotFoundException;
import com.example.driverservice.repository.DriverRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DriverService {
    private final DriverRepository repository;

    public DriverService(DriverRepository repository) {
        this.repository = repository;
    }

    public List<Driver> getAllDrivers() {
        return repository.findAll();
    }

    public Driver getDriver(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new DriverNotFoundException(id));
    }

    public Driver addDriver(Driver driver) {
        return repository.save(driver);
    }

    public Driver updateDriver(Long id, Driver newDriver) {
        return repository.findById(id)
                .map(driver -> {
                    driver.setName(newDriver.getName());
                    driver.setEmail(newDriver.getEmail());
                    return repository.save(driver);
                })
                .orElseGet(() -> {
                    newDriver.setId(id);
                    return repository.save(newDriver);
                });
    }

    public void deleteDriver(Long id) {
        repository.deleteById(id);
    }
}
