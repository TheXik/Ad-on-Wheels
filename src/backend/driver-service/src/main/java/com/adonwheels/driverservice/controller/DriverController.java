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
import org.springframework.web.server.ResponseStatusException;

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

    @PostMapping
    public ResponseEntity<ApiResponse<Driver>> newDriver(@Valid @RequestBody Driver newDriver) {
        Driver savedDriver = service.addDriver(newDriver);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(savedDriver));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Driver>> one(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, id);
        Driver driver = service.getDriver(id);
        return ResponseEntity.ok(ApiResponse.success(driver));
    }

    // Internal batch lookup for the company BFF aggregator. Restricted to ADMIN
    // (the BFF stamps this) so a driver cannot enumerate other drivers.
    @GetMapping
    public ResponseEntity<ApiResponse<List<Driver>>> driversByIds(
            @RequestParam("ids") List<Long> ids,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        if (!"ADMIN".equals(callerRole)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Caller is not authorized to act on this resource");
        }
        return ResponseEntity.ok(ApiResponse.success(service.getDriversByIds(ids)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Driver>> replaceDriver(
            @Valid @RequestBody Driver newDriver,
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, id);
        Driver updatedDriver = service.updateDriver(id, newDriver);
        return ResponseEntity.ok(ApiResponse.success(updatedDriver));
    }

    @PatchMapping("/{id}/vehicle")
    public ResponseEntity<ApiResponse<Driver>> addVehicle(
            @PathVariable Long id,
            @Valid @RequestBody VehicleRequest vehicle,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, id);
        Driver updatedDriver = service.addVehicle(id, vehicle);
        return ResponseEntity.ok(ApiResponse.success(updatedDriver));
    }

    @PatchMapping("/{id}/onboarding")
    public ResponseEntity<ApiResponse<Driver>> completeOnboarding(
            @PathVariable Long id,
            @Valid @RequestBody OnboardingRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, id);
        Driver updatedDriver = service.completeOnboarding(id, request);
        return ResponseEntity.ok(ApiResponse.success(updatedDriver));
    }

    @PostMapping("/{id}/vehicle-image")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadVehicleImage(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, id);
        String key = imageService.upload(id, file);
        String imageUrl = "/api/drivers/images/" + key;
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
    public ResponseEntity<ApiResponse<Void>> deleteDriver(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, id);
        service.deleteDriver(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // The gateway role-class gate (A3) only proves "this caller has DRIVER or
    // ADMIN role". This per-endpoint check pins the specific driver id so a
    // driver cannot read or mutate another driver's profile.
    private void requireOwnership(Long callerId, String callerRole, Long pathOwnerId) {
        if ("ADMIN".equals(callerRole)) {
            return;
        }
        if (callerId == null || !callerId.equals(pathOwnerId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Caller is not authorized to act on this resource");
        }
    }
}
