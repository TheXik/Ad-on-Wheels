package com.example.driverservice;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;

import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.server.RepresentationModelAssembler;
import org.springframework.stereotype.Component;

@Component
public class DriverModelAssembler implements RepresentationModelAssembler<Driver, EntityModel<Driver>> {
    @Override
    public EntityModel<Driver> toModel(Driver driver) {
        return EntityModel.of(driver,
            linkTo(methodOn(DriverController.class).one(driver.getId())).withSelfRel(),
            linkTo(methodOn(DriverController.class).all()).withRel("drivers")
        );
    }
} 