package com.adonwheels.authservice.service;

import com.adonwheels.authservice.model.User;
import com.adonwheels.authservice.repository.AuthRepository;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Service
public class JWTService {
    @Value("${jwt.secret}")
    public String secretKey;

    @Value("${jwt.expiration-ms}")
    private long expirationTime;

    @Autowired
    private AuthRepository authRepository;
// Commented out cuz i am now using a one secret key thats stored in the .env files TODO review this approach later
//    public JWTService() {
//        try {
//            KeyGenerator keyGenerator = KeyGenerator.getInstance("HmacSHA256");
//            SecretKey sk = keyGenerator.generateKey();
//            secretKey = Base64.getEncoder().encodeToString(sk.getEncoded());
//            System.out.println("SECRET KEY " + secretKey);
//
//        } catch (NoSuchAlgorithmException e) {
//            throw new RuntimeException(e);
//
//        }
//    }


    // TODO IS it correct to return as a string ?
    public String generateToken(String email) {

        User user = authRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found for token generation"));


        Map<String, Object> claims = new HashMap<>();
        claims.put("role", user.getRole().name());
        claims.put("profileID", user.getProfileId());


        return Jwts.builder()
                .claims()
                .add(claims)
                .subject(user.getEmail())
                .issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis() + expirationTime))
                .and()
                .signWith(getSigningKey())
                .compact();

    }
    private Key getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
