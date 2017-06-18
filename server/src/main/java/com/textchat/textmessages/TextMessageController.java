package com.textchat.textmessages;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.persistence.textmessages.TextMessageRepository;
import com.textchat.persistence.textmessages.TextMessageRow;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.annotation.SubscribeMapping;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static java.util.Collections.singletonList;

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
        Iterable<TextMessageRow> textMessageRows = textMessageRepository.findLatestThreads();

        ArrayList<TextMessageResponse> textMessageResponses = new ArrayList<>();

        for (TextMessageRow textMessageRow : textMessageRows) {
            TextMessageResponse textMessageResponse = new TextMessageResponse(textMessageRow);
            textMessageResponses.add(textMessageResponse);
        }

        // TODO: normalize the data (return a list of textmessages with contact ids and a list of the corresponding contacts)
        return textMessageResponses;
    }

    // To make the channels dynamic, see: https://stackoverflow.com/questions/27047310/path-variables-in-spring-websockets-sendto-mapping
    @MessageMapping("/create-text-message")
    @SendTo("/text-messages")
    public List<TextMessageResponse> sendMessage(@RequestBody SendMessageRequest sendMessageRequest) {
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

        return singletonList(new TextMessageResponse(textMessageRow));
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
}
