package com.adonwheels.driverservice.service;

import com.adonwheels.driverservice.dto.OnboardingRequest;
import com.adonwheels.driverservice.dto.VehicleRequest;
import com.adonwheels.driverservice.model.Driver;
import com.adonwheels.driverservice.exception.DriverNotFoundException;
import com.adonwheels.driverservice.repository.DriverRepository;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class DriverService {
    private final DriverRepository repository;

    public DriverService(DriverRepository repository) {
        this.repository = repository;
    }

    public Driver getDriver(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new DriverNotFoundException(id));
    }

    public List<Driver> getDriversByIds(List<Long> ids) {
        return repository.findAllById(ids);
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
    public Driver addVehicle(Long id, VehicleRequest vehicle) {
        Driver driver = repository.findById(id)
                .orElseThrow(() -> new DriverNotFoundException(id));
        driver.setVehicleMake(vehicle.make());
        driver.setVehicleModel(vehicle.model());
        driver.setVehicleYear(vehicle.year());
        driver.setVehiclePlate(vehicle.licensePlate());
        return repository.save(driver);
    }

    @Transactional
    public Driver completeOnboarding(Long id, OnboardingRequest request) {
        Driver driver = repository.findById(id)
                .orElseThrow(() -> new DriverNotFoundException(id));
        driver.setVehicleMake(request.make());
        driver.setVehicleModel(request.model());
        driver.setVehicleYear(request.year());
        driver.setVehiclePlate(request.licensePlate());
        driver.setVehicleImageUrl(request.vehicleImageUrl());
        driver.setMonthlyGoalKm(request.monthlyGoalKm());
        driver.setOnboardingCompleted(true);
        return repository.save(driver);
    }

    @Transactional
    public void deleteDriver(Long id) {
        try {
            repository.deleteById(id);
        } catch (EmptyResultDataAccessException e) {
            // Idempotent: already-deleted is success.
        }
    }
}
