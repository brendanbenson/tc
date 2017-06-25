package com.textchat.textmessages;

import com.fasterxml.jackson.annotation.JsonProperty;

public class TwilioSmsRequest {
    @JsonProperty("Body")
    String body;
    @JsonProperty("From")
    String from;
    @JsonProperty("To")
    String to;

    public TwilioSmsRequest() {
    }

    public String getBody() {
        return body;
    }

    public String getFrom() {
        return from;
    }

    public String getTo() {
        return to;
    }
}
