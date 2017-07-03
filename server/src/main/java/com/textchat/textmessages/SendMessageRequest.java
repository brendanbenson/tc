package com.textchat.textmessages;

public class SendMessageRequest {
    private String body;

    public SendMessageRequest() {
    }

    public SendMessageRequest(String body) {
        this.body = body;
    }

    public String getBody() {
        return body;
    }
}
