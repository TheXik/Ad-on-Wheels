package com.adonwheels.companyservice;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@EnabledIfEnvironmentVariable(named = "RUN_CONTEXT_LOADS", matches = "true")
class CompanyServiceApplicationTests {

    @Test
    void contextLoads() {
    }

}
