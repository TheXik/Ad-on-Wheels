package com.example.driverservice.service;

import com.example.driverservice.model.Driver;
import com.example.driverservice.exception.DriverNotFoundException;
import com.example.driverservice.repository.DriverRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Transactional
    public Driver addDriver(Driver driver) {
        return repository.save(driver);
    }

    @Transactional
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

    @Transactional
    public Driver addVehicle(Long id, com.example.driverservice.dto.VehicleRequest vehicle) {
        Driver driver = repository.findById(id)
                .orElseThrow(() -> new DriverNotFoundException(id));
        driver.setVehicleMake(vehicle.getMake());
        driver.setVehicleModel(vehicle.getModel());
        driver.setVehicleYear(vehicle.getYear());
        driver.setVehiclePlate(vehicle.getLicensePlate());
        driver.setVehicleColor(vehicle.getColor());
        driver.setVehicleVerified(false); // always requires re-verification on update
        return repository.save(driver);
    }

    @Transactional
    public void deleteDriver(Long id) {
        try {
            repository.deleteById(id);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            // Idempotent delete: if it's already gone, we don't care.
        }
    }
}
