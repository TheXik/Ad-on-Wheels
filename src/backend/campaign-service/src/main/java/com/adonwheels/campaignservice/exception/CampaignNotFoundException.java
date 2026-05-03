package com.adonwheels.campaignservice.exception;

import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;

public class CampaignNotFoundException extends BusinessException {
    public CampaignNotFoundException(Long id) {
        super(AppErrorCode.CAMPAIGN_NOT_FOUND, "Campaign not found with id " + id);
    }
}
