package com.example.driverservice.controller;

import com.example.driverservice.assembler.DriverModelAssembler;
import com.example.driverservice.model.Driver;
import com.example.driverservice.service.DriverService;
import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.IanaLinkRelations;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;

import jakarta.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/drivers")
public class DriverController {
    private final DriverService service;
    private final DriverModelAssembler assembler;

    public DriverController(DriverService service, DriverModelAssembler assembler) {
        this.service = service;
        this.assembler = assembler;
    }

    // GET /drivers Returns a collection of all drivers
    @GetMapping
    public CollectionModel<EntityModel<Driver>> all() {
        List<EntityModel<Driver>> drivers = service.getAllDrivers().stream()
            .map(assembler::toModel)
            .collect(Collectors.toList());
        return CollectionModel.of(drivers,
            org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo(
                org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn(DriverController.class).all()
            ).withSelfRel()
        );
    }

    // POST /drivers Creates a new driver
    @PostMapping
    public ResponseEntity<?> newDriver(@Valid @RequestBody Driver newDriver) {
        EntityModel<Driver> entityModel = assembler.toModel(service.addDriver(newDriver));
        return ResponseEntity
            .created(entityModel.getRequiredLink(IanaLinkRelations.SELF).toUri())
            .body(entityModel);
    }

    // GET /drivers/{id} Returns a single driver by ID
    @GetMapping("/{id}")
    public EntityModel<Driver> one(@PathVariable Long id) {
        Driver driver = service.getDriver(id);
        return assembler.toModel(driver);
    }

    // PUT /drivers/{id} Updates an existing driver by ID
    @PutMapping("/{id}")
    public ResponseEntity<?> replaceDriver(@Valid @RequestBody Driver newDriver, @PathVariable Long id) {
        Driver updatedDriver = service.updateDriver(id, newDriver);
        EntityModel<Driver> entityModel = assembler.toModel(updatedDriver);
        return ResponseEntity
            .created(entityModel.getRequiredLink(IanaLinkRelations.SELF).toUri())
            .body(entityModel);
    }

    // DELETE /drivers/{id} Deletes a driver by ID
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteDriver(@PathVariable Long id) {
        service.deleteDriver(id);
    }
} 