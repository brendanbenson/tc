package com.textchat.textmessages;

import com.textchat.persistence.textmessages.TextMessage;

public interface TextMessageGateway {
    void send(TextMessage textMessage);
}
