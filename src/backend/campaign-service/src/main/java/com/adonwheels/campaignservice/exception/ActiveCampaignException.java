package com.adonwheels.campaignservice.exception;

import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;

public class ActiveCampaignException extends BusinessException {
    public ActiveCampaignException(Long driverId) {
        super(AppErrorCode.DRIVER_HAS_ACTIVE_CAMPAIGN,
                "Driver " + driverId + " already has an active campaign");
    }
}
