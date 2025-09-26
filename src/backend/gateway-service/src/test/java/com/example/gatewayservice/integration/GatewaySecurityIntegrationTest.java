package com.example.gatewayservice.integration;

import com.example.gatewayservice.util.TestJwtUtil; // Import our new test utility
import com.github.tomakehurst.wiremock.client.WireMock;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.cloud.contract.wiremock.AutoConfigureWireMock;
import org.springframework.test.web.reactive.server.WebTestClient;

import static com.github.tomakehurst.wiremock.client.WireMock.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = {
                "spring.cloud.discovery.client.simple.instances.auth-service[0].uri=http://localhost:${wiremock.server.port}",
                "spring.cloud.discovery.client.simple.instances.campaign-service[0].uri=http://localhost:${wiremock.server.port}",
                "spring.cloud.discovery.client.simple.instances.driver-service[0].uri=http://localhost:${wiremock.server.port}"
        })
@AutoConfigureWireMock(port = 0)
public class GatewaySecurityIntegrationTest {

    @Autowired
    private WebTestClient webTestClient;

    private String testToken;
    private final TestJwtUtil testJwtUtil = new TestJwtUtil();

    @BeforeEach
    void setUp() {
        testToken = testJwtUtil.generateToken("testuser");
        WireMock.reset();
    }

    @Test
    void whenAccessingProtectedEndpointWithoutToken_thenReturns401Unauthorized() {
        webTestClient
                .get().uri("/campaigns/1")
                .exchange()
                .expectStatus().isUnauthorized();
    }

    @Test
    void whenAccessingPublicEndpoint_thenForwardsRequestSuccessfully() {
        //arange
        stubFor(post(urlEqualTo("/auth/login"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", "application/json")
                        .withBody("{\"token\":\"mock-jwt-token\"}")));
        // Act && assert
        webTestClient
                .post().uri("/auth/login")
                .exchange()
                .expectStatus().isOk();
    }

    @Test
    void whenAccessingProtectedEndpointWithValidToken_thenForwardsRequestSuccessfully() {
        //arange

        stubFor(get(urlEqualTo("/campaigns/1"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", "application/json")
                        .withBody("{\"campaignName\":\"Test Campaign\"}")));
        // Act && assert
        webTestClient
                .get().uri("/campaigns/1")
                .header("Authorization", "Bearer " + testToken)
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.campaignName").isEqualTo("Test Campaign");
    }

   
}