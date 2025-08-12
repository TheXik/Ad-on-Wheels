package com.adonwheels.authservice.config;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class AppConfig {

    // TODO : MOVE THIS SOMEWHERE ELSE I dont think its a good practice to expose beans inside the app config class
    @Bean
    @LoadBalanced // This enables client-side load balancing with Eureka
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}