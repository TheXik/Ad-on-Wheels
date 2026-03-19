package com.adonwheels.gatewayservice.config;

import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class WebClientConfig {

    @Bean
    @LoadBalanced
    public WebClient.Builder loadBalancedWebClientBuilder() {
        return WebClient.builder();
    }

    @Bean
    public WebClient campaignClient(WebClient.Builder webClientBuilder) {
        return webClientBuilder.baseUrl("http://CAMPAIGN-SERVICE").build();
    }


    @Bean
    public WebClient driverClient(WebClient.Builder webClientBuilder) {
        return webClientBuilder.baseUrl("http://DRIVER-SERVICE").build();
    }

    @Bean
    public WebClient rideClient(WebClient.Builder webClientBuilder) {
        return webClientBuilder.baseUrl("http://RIDE-SERVICE").build();
    }
} 