package com.adonwheels.driverservice.controller;

import com.adonwheels.driverservice.dto.OnboardingRequest;
import com.adonwheels.driverservice.dto.VehicleRequest;
import com.adonwheels.driverservice.model.Driver;
import com.adonwheels.driverservice.service.DriverService;
import com.adonwheels.driverservice.service.VehicleImageService;
import dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/drivers")
public class DriverController {

    private final DriverService service;
    private final VehicleImageService imageService;

    public DriverController(DriverService service, VehicleImageService imageService) {
        this.service = service;
        this.imageService = imageService;
    }

    // GET /drivers — list all drivers
    @GetMapping
    public ResponseEntity<ApiResponse<List<Driver>>> all() {
        List<Driver> drivers = service.getAllDrivers();
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(drivers));
    }

    // POST /drivers — register a new driver
    @PostMapping
    public ResponseEntity<ApiResponse<Driver>> newDriver(@Valid @RequestBody Driver newDriver) {
        Driver savedDriver = service.addDriver(newDriver);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(savedDriver));
    }

    // GET /drivers/{id} — get a single driver
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Driver>> one(@PathVariable Long id) {
        Driver driver = service.getDriver(id);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(driver));
    }

    // PUT /drivers/{id} — replace a driver profile
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Driver>> replaceDriver(
            @Valid @RequestBody Driver newDriver,
            @PathVariable Long id) {
        Driver updatedDriver = service.updateDriver(id, newDriver);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(updatedDriver));
    }

    // PATCH /drivers/{id}/vehicle — add or update vehicle info for a driver
    @PatchMapping("/{id}/vehicle")
    public ResponseEntity<ApiResponse<Driver>> addVehicle(
            @PathVariable Long id,
            @Valid @RequestBody VehicleRequest vehicle) {
        Driver updatedDriver = service.addVehicle(id, vehicle);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(updatedDriver));
    }

    @PatchMapping("/{id}/onboarding")
    public ResponseEntity<ApiResponse<Driver>> completeOnboarding(
            @PathVariable Long id,
            @Valid @RequestBody OnboardingRequest request) {
        Driver updatedDriver = service.completeOnboarding(id, request);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(updatedDriver));
    }

    @PostMapping("/{id}/vehicle-image")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadVehicleImage(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file) {
        String key = imageService.upload(id, file);
        String imageUrl = "/drivers/images/" + key;
        return ResponseEntity.ok(ApiResponse.success(Map.of("imageUrl", imageUrl)));
    }

    @GetMapping("/images/**")
    public ResponseEntity<byte[]> serveImage(jakarta.servlet.http.HttpServletRequest request) {
        String fullPath = request.getRequestURI();
        String key = fullPath.substring(fullPath.indexOf("/images/") + "/images/".length());
        byte[] data = imageService.download(key);
        String contentType = imageService.getContentType(key);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .body(data);
    }

    // DELETE /drivers/{id} — remove a driver
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Object>> deleteDriver(@PathVariable Long id) {
        service.deleteDriver(id);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(null));
    }
}
