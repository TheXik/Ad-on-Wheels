package com.example.driverservice.assembler;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;

import com.example.driverservice.controller.DriverController;
import com.example.driverservice.model.Driver;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.server.RepresentationModelAssembler;
import org.springframework.hateoas.server.mvc.WebMvcLinkBuilder;
import org.springframework.stereotype.Component;

@Component
public class DriverModelAssembler implements RepresentationModelAssembler<Driver, EntityModel<Driver>> {
    @Override
    public EntityModel<Driver> toModel(Driver driver) {
        return EntityModel.of(driver,
            WebMvcLinkBuilder.linkTo(methodOn(DriverController.class).one(driver.getId())).withSelfRel(),
            linkTo(methodOn(DriverController.class).all()).withRel("drivers")
        );
    }
} 