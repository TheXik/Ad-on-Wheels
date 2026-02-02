package com.example.driverservice.controller;

import com.example.driverservice.model.Driver;
import com.example.driverservice.service.DriverService;
import dto.ApiResponse;
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
    public ResponseEntity<ApiResponse<List<Driver>>> all() {
        List<Driver> drivers = service.getAllDrivers();
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(drivers));
    }

    // POST /drivers Creates a new driver
    @PostMapping
    public ResponseEntity<ApiResponse<Driver>> newDriver(@Valid @RequestBody Driver newDriver) {
        Driver savedDriver = service.addDriver(newDriver);
        return ResponseEntity // TODO Cross site scripting vulnerability sink
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(savedDriver));
    }

    // GET /drivers/{id} Returns a single driver by ID
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Driver>> one(@PathVariable("id") Long id) {
        Driver driver = service.getDriver(id);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(driver));
    }

    // PUT /drivers/{id} Updates an existing driver by ID
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Driver>> replaceDriver(@Valid @RequestBody Driver newDriver, @PathVariable("id") Long id) {
        Driver updatedDriver = service.updateDriver(id, newDriver);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(updatedDriver));
    }

    // DELETE /drivers/{id} Deletes a driver by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Object>> deleteDriver(@PathVariable("id") Long id) {
        service.deleteDriver(id);
        // For consistency, I am returning ApiResponse always even though it goes against best practices
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(null));

    }
} 