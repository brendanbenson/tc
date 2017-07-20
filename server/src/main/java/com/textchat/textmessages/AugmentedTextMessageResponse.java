package com.textchat.textmessages;

import java.util.List;

public class AugmentedTextMessageResponse {
    private List<TextMessageResponse> textMessages;
    private List<ContactResponse> contacts;

    public AugmentedTextMessageResponse() {
    }

    public AugmentedTextMessageResponse(List<TextMessageResponse> textMessages, List<ContactResponse> contacts) {
        this.textMessages = textMessages;
        this.contacts = contacts;
    }

    public List<TextMessageResponse> getTextMessages() {
        return textMessages;
    }

    public List<ContactResponse> getContacts() {
        return contacts;
    }
}
