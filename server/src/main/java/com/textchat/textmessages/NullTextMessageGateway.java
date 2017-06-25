package com.textchat.textmessages;

import com.textchat.persistence.textmessages.TextMessage;

public class NullTextMessageGateway implements TextMessageGateway {
    @Override
    public void send(TextMessage textMessage) {
    }
}
