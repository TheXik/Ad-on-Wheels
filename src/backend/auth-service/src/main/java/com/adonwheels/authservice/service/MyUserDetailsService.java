package com.adonwheels.authservice.service;

import com.adonwheels.authservice.model.CustomUserDetails;
import com.adonwheels.authservice.model.User;
import com.adonwheels.authservice.repository.AuthRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

///MyUserDetailsService is a highly specialized component that acts as the bridge between
///our user data and the security framework.
@Service
public class MyUserDetailsService implements UserDetailsService {

    @Autowired
    private AuthRepository authRepository;
    
    
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User credential = authRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));
        return new CustomUserDetails(credential);
    }
}
