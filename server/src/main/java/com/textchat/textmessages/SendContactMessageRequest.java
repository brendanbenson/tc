package com.textchat.textmessages;

public class SendContactMessageRequest {
    private String body;

    public SendContactMessageRequest() {
    }

    public SendContactMessageRequest(String body) {
        this.body = body;
    }

    public String getBody() {
        return body;
    }
}
