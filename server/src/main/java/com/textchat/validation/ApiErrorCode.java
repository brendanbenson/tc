package com.textchat.validation;

public enum ApiErrorCode {
    ALREADY_EXISTS("AlreadyExists"), INVALID_PHONE_NUMBER("InvalidPhoneNumber");

    private String code;

    ApiErrorCode(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }
}
