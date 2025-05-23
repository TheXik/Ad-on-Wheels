package com.example.driverservice;

import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.IanaLinkRelations;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;

import jakarta.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/drivers")
public class DriverController {
    private final DriverRepository repository;
    private final DriverModelAssembler assembler;

    @Autowired
    public DriverController(DriverRepository repository, DriverModelAssembler assembler) {
        this.repository = repository;
        this.assembler = assembler;
    }

    @GetMapping
    public CollectionModel<EntityModel<Driver>> all() {
        List<EntityModel<Driver>> drivers = repository.findAll().stream()
            .map(assembler::toModel)
            .collect(Collectors.toList());
        return CollectionModel.of(drivers,
            org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo(
                org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn(DriverController.class).all()
            ).withSelfRel()
        );
    }

    @PostMapping
    public ResponseEntity<?> newDriver(@Valid @RequestBody Driver newDriver) {
        EntityModel<Driver> entityModel = assembler.toModel(repository.save(newDriver));
        return ResponseEntity
            .created(entityModel.getRequiredLink(IanaLinkRelations.SELF).toUri())
            .body(entityModel);
    }

    @GetMapping("/{id}")
    public EntityModel<Driver> one(@PathVariable Long id) {
        Driver driver = repository.findById(id)
            .orElseThrow(() -> new DriverNotFoundException(id));
        return assembler.toModel(driver);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> replaceDriver(@Valid @RequestBody Driver newDriver, @PathVariable Long id) {
        Driver updatedDriver = repository.findById(id)
            .map(driver -> {
                driver.setName(newDriver.getName());
                driver.setEmail(newDriver.getEmail());
                return repository.save(driver);
            })
            .orElseGet(() -> {
                newDriver.setId(id);
                return repository.save(newDriver);
            });
        EntityModel<Driver> entityModel = assembler.toModel(updatedDriver);
        return ResponseEntity
            .created(entityModel.getRequiredLink(IanaLinkRelations.SELF).toUri())
            .body(entityModel);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteDriver(@PathVariable Long id) {
        repository.deleteById(id);
    }
} 