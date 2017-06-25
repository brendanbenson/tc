package com.textchat.textmessages;

public class SendMessageRequest {
    private String body;
    private String toPhoneNumber;

    public SendMessageRequest() {
    }

    public SendMessageRequest(String body, String toPhoneNumber) {
        this.body = body;
        this.toPhoneNumber = toPhoneNumber;
    }

    public String getBody() {
        return body;
    }

    public String getToPhoneNumber() {
        return toPhoneNumber;
    }
}
