package com.textchat.twilio;

import com.textchat.textmessages.TextMessage;
import com.textchat.textmessages.TextMessageGateway;
import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.rest.api.v2010.account.MessageCreator;
import com.twilio.type.PhoneNumber;

public class TwilioTextMessageGateway implements TextMessageGateway {
    public TwilioTextMessageGateway(String accountSid, String authToken) {
        Twilio.init(accountSid, authToken);
    }

    @Override
    public void send(TextMessage textMessage) {
        MessageCreator messageCreator = Message.creator(
                new PhoneNumber(textMessage.getToPhoneNumber()),
                new PhoneNumber(textMessage.getFromPhoneNumber()),
                textMessage.getBody()
        );

        Message message = messageCreator.create();
        System.out.println("Text message sent: " + message.getSid());
    }
}
