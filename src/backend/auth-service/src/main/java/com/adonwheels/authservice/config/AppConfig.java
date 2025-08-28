package com.adonwheels.authservice.config;

import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;
@Configuration
public class AppConfig {

    @Bean
    @LoadBalanced // This enables client-side load balancing with Eureka for WebClient
    public WebClient.Builder webClientBuilder() {
        return WebClient.builder();
    }
}