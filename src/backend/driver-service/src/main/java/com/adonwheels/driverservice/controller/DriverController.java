package com.adonwheels.driverservice.controller;

import com.adonwheels.driverservice.dto.OnboardingRequest;
import com.adonwheels.driverservice.dto.VehicleRequest;
import com.adonwheels.driverservice.model.Driver;
import com.adonwheels.driverservice.service.DriverService;
import com.adonwheels.driverservice.service.VehicleImageService;
import com.adonwheels.dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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

    @PostMapping
    public ResponseEntity<ApiResponse<Driver>> newDriver(@Valid @RequestBody Driver newDriver) {
        Driver savedDriver = service.addDriver(newDriver);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(savedDriver));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Driver>> one(@PathVariable Long id) {
        Driver driver = service.getDriver(id);
        return ResponseEntity.ok(ApiResponse.success(driver));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Driver>> replaceDriver(
            @Valid @RequestBody Driver newDriver,
            @PathVariable Long id) {
        Driver updatedDriver = service.updateDriver(id, newDriver);
        return ResponseEntity.ok(ApiResponse.success(updatedDriver));
    }

    @PatchMapping("/{id}/vehicle")
    public ResponseEntity<ApiResponse<Driver>> addVehicle(
            @PathVariable Long id,
            @Valid @RequestBody VehicleRequest vehicle) {
        Driver updatedDriver = service.addVehicle(id, vehicle);
        return ResponseEntity.ok(ApiResponse.success(updatedDriver));
    }

    @PatchMapping("/{id}/onboarding")
    public ResponseEntity<ApiResponse<Driver>> completeOnboarding(
            @PathVariable Long id,
            @Valid @RequestBody OnboardingRequest request) {
        Driver updatedDriver = service.completeOnboarding(id, request);
        return ResponseEntity.ok(ApiResponse.success(updatedDriver));
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

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteDriver(@PathVariable Long id) {
        service.deleteDriver(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
