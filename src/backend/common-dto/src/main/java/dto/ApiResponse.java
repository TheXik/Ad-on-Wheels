package dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import dto.ErrorResponse;


@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private final boolean success;
    private T data;
    private ErrorResponse error;

    private ApiResponse(boolean success) {
        this.success = success;
    }


    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> response = new ApiResponse<>(true);
        response.setData(data);
        return response;
    }

    public static <T> ApiResponse<T> error(int status, String message) {
        ApiResponse<T> response = new ApiResponse<>(false);
        response.setError(new ErrorResponse(status, message));
        return response;
    }

    public boolean isSuccess() {
        return success;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public ErrorResponse getError() {
        return error;
    }

    public void setError(ErrorResponse error) {
        this.error = error;
    }
}