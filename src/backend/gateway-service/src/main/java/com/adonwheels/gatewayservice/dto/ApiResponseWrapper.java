package com.adonwheels.gatewayservice.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.Map;

public class ApiResponseWrapper<T> {
    private boolean success;
    private T data;

    @JsonProperty("error")
    private Object error;

    public ApiResponseWrapper() {
    }

    public ApiResponseWrapper(boolean success, T data, Object error) {
        this.success = success;
        this.data = data;
        this.error = error;
    }

    public static <T> ApiResponseWrapper<T> success(T data) {
        return new ApiResponseWrapper<>(true, data, null);
    }

    public static <T> ApiResponseWrapper<T> error(int internalCode, String message) {
        ApiResponseWrapper<T> wrapper = new ApiResponseWrapper<>();
        wrapper.setSuccess(false);
        wrapper.setError(Map.of("internalCode", internalCode, "message", message));
        return wrapper;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public Object getError() {
        return error;
    }

    public void setError(Object error) {
        this.error = error;
    }
}
