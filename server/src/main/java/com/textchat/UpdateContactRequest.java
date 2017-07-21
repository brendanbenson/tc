package com.textchat;

class UpdateContactRequest {
    private Long id;
    private String phoneNumber;
    private String label;

    public Long getId() {
        return id;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getLabel() {
        return label;
    }
}
