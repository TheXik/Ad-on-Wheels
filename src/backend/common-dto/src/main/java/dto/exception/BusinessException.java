package dto.exception;

import dto.AppErrorCode;

public class BusinessException extends RuntimeException {
    private final AppErrorCode errorCode;

    public BusinessException(AppErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }

    public BusinessException(AppErrorCode errorCode, String customMessage) {
        super(customMessage);
        this.errorCode = errorCode;
    }

    public AppErrorCode getErrorCode() {
        return errorCode;
    }
}
