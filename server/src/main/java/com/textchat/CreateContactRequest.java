package com.textchat;

import org.hibernate.validator.constraints.NotBlank;

class CreateContactRequest {
    private String label;
    @NotBlank
    private String phoneNumber;

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getLabel() {
        return label;
    }
}
