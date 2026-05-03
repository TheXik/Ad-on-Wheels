package com.adonwheels.gatewayservice.util;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class TestJwtUtil {

    // Must match the value in src/test/resources/application.properties.
    public static final String SECRET = "061d8ac927d6141740f69533c41e2a8e39fd10126baf26e49bee15f3f93f8ac840a631979ed33361";

    public String generateToken(String userName, String role, String profileId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("role", role);
        claims.put("profileID", profileId);
        return createToken(claims, userName);
    }

    private String createToken(Map<String, Object> claims, String subject) {
        long expirationTime = 1000L * 60 * 30;

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + expirationTime))
                .signWith(getSignKey())
                .compact();
    }

    private Key getSignKey() {
        byte[] keyBytes = Decoders.BASE64.decode(SECRET);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
