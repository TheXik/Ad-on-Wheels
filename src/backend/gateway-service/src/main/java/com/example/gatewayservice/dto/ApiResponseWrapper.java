package com.example.gatewayservice.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

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
