package com.adonwheels.campaignservice.config;

import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

// Synchronous HTTP client for the daily lifecycle scheduler. RestClient is the
// non-reactive Spring 6 successor to RestTemplate; @LoadBalanced lets us call
// services by Eureka name (e.g. http://ride-service/...). The scheduler is a
// once-a-day pass off the request thread, so blocking is acceptable here.
@Configuration
public class RestClientConfig {

    @Bean
    @LoadBalanced
    public RestClient.Builder loadBalancedRestClientBuilder() {
        return RestClient.builder();
    }

    @Bean
    public RestClient rideClient(RestClient.Builder builder) {
        return builder.baseUrl("http://RIDE-SERVICE").build();
    }
}
