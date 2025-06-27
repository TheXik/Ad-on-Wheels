package com.example.driverservice.controller;

import com.example.driverservice.model.Driver;
import com.example.driverservice.service.DriverService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/drivers")
public class DriverController {
    private final DriverService service;

    public DriverController(DriverService service) {
        this.service = service;
    }

    // GET /drivers Returns a collection of all drivers
    @GetMapping
    public List<Driver> all() {
        return service.getAllDrivers();
    }

    // POST /drivers Creates a new driver
    @PostMapping
    public ResponseEntity<Driver> newDriver(@Valid @RequestBody Driver newDriver) {
        Driver savedDriver = service.addDriver(newDriver);
        return ResponseEntity.ok(savedDriver);
    }

    // GET /drivers/{id} Returns a single driver by ID
    @GetMapping("/{id}")
    public ResponseEntity<Driver> one(@PathVariable Long id) {
        Driver driver = service.getDriver(id);
        return ResponseEntity.ok(driver);
    }

    // PUT /drivers/{id} Updates an existing driver by ID
    @PutMapping("/{id}")
    public ResponseEntity<Driver> replaceDriver(@Valid @RequestBody Driver newDriver, @PathVariable Long id) {
        Driver updatedDriver = service.updateDriver(id, newDriver);
        return ResponseEntity.ok(updatedDriver);
    }

    // DELETE /drivers/{id} Deletes a driver by ID
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteDriver(@PathVariable Long id) {
        service.deleteDriver(id);
    }
} 