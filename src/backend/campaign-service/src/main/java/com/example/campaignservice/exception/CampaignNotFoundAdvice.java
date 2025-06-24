package com.example.campaignservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@ControllerAdvice
public class CampaignNotFoundAdvice {
    @ResponseBody
    @ExceptionHandler(CampaignNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    String campaignNotFoundHandler(CampaignNotFoundException ex) {
        return ex.getMessage();
    }
} 