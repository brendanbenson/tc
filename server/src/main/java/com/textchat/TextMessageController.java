package com.textchat;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.persistence.textmessages.TextMessageRepository;
import com.textchat.persistence.textmessages.TextMessageRow;
import com.textchat.textmessages.TextMessage;
import com.textchat.textmessages.TextMessageGateway;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.annotation.SubscribeMapping;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

@Controller
public class TextMessageController {
    private TextMessageGateway textMessageGateway;
    private TextMessageRepository textMessageRepository;
    private ContactRepository contactRepository;

    @Autowired
    public TextMessageController(
            TextMessageGateway textMessageGateway,
            TextMessageRepository textMessageRepository,
            ContactRepository contactRepository
    ) {
        this.textMessageGateway = textMessageGateway;
        this.textMessageRepository = textMessageRepository;
        this.contactRepository = contactRepository;
    }

    @SubscribeMapping("/text-messages")
    public List<TextMessageResponse> getMessages() {
        Iterable<TextMessageRow> textMessageRows = textMessageRepository.findAll();

        ArrayList<TextMessageResponse> textMessageResponses = new ArrayList<>();

        Iterator<TextMessageRow> iterator = textMessageRows.iterator();

        iterator.forEachRemaining(textMessageRow -> {
            TextMessageResponse textMessageResponse = TextMessageResponse.fromTextMessageRow(textMessageRow);
            textMessageResponses.add(textMessageResponse);
        });

        return textMessageResponses;
    }

    // To make the channels dynamic, see: https://stackoverflow.com/questions/27047310/path-variables-in-spring-websockets-sendto-mapping
    @MessageMapping("/create-text-message")
    @SendTo("/text-messages")
    public TextMessageResponse sendMessage(@RequestBody SendMessageRequest sendMessageRequest) {
        String fromPhoneNumber = "+12486004432";

        Contact fromContact = contactRepository.findByPhoneNumber(fromPhoneNumber);

        if (fromContact == null) {
            fromContact = contactRepository.save(new Contact(fromPhoneNumber, ""));
        }

        Contact toContact = contactRepository.findByPhoneNumber(sendMessageRequest.toPhoneNumber);

        if (toContact == null) {
            toContact = contactRepository.save(new Contact(sendMessageRequest.toPhoneNumber, ""));
        }

        TextMessageRow textMessageRow = new TextMessageRow(sendMessageRequest.getBody(), toContact, fromContact);

        textMessageRepository.save(textMessageRow);

        TextMessage textMessage = new TextMessage(sendMessageRequest.getBody(), sendMessageRequest.getToPhoneNumber(), fromPhoneNumber);

        textMessageGateway.send(textMessage);

        return TextMessageResponse.fromTextMessageRow(textMessageRow);
    }

    private static class SendMessageRequest {
        private String body;
        private String toPhoneNumber;

        public String getBody() {
            return body;
        }

        public String getToPhoneNumber() {
            return toPhoneNumber;
        }
    }

    private static class TextMessageResponse {
        private String body;
        private String toPhoneNumber;
        private String toLabel;

        public TextMessageResponse(String body, String toPhoneNumber, String toLabel) {
            this.body = body;
            this.toPhoneNumber = toPhoneNumber;
            this.toLabel = toLabel;
        }

        public static TextMessageResponse fromTextMessageRow(TextMessageRow textMessageRow) {
            return new TextMessageResponse(
                    textMessageRow.getBody(),
                    textMessageRow.getToPhoneNumber(),
                    textMessageRow.getToLabel()
            );
        }

        public String getBody() {
            return body;
        }

        public String getToPhoneNumber() {
            return toPhoneNumber;
        }

        public String getToLabel() {
            return toLabel;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            TextMessageResponse that = (TextMessageResponse) o;

            if (body != null ? !body.equals(that.body) : that.body != null) return false;
            return toPhoneNumber != null ? toPhoneNumber.equals(that.toPhoneNumber) : that.toPhoneNumber == null;
        }

        @Override
        public int hashCode() {
            int result = body != null ? body.hashCode() : 0;
            result = 31 * result + (toPhoneNumber != null ? toPhoneNumber.hashCode() : 0);
            return result;
        }
    }
}
