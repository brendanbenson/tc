package com.textchat.textmessages;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.persistence.textmessages.TextMessageRepository;
import com.textchat.persistence.textmessages.TextMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class TextMessageService {
    private TextMessageGateway textMessageGateway;
    private TextMessageRepository textMessageRepository;
    private ContactRepository contactRepository;

    @Autowired
    public TextMessageService(
            TextMessageGateway textMessageGateway,
            TextMessageRepository textMessageRepository,
            ContactRepository contactRepository
    ) {
        this.textMessageGateway = textMessageGateway;
        this.textMessageRepository = textMessageRepository;
        this.contactRepository = contactRepository;
    }

    // TODO: create a send method that takes a contact id instead of a phone number

    public TextMessage send(String toPhoneNumber, String body) {
        String fromPhoneNumber = "+12486004432";

        Contact fromContact = contactRepository.findByPhoneNumber(fromPhoneNumber);

        if (fromContact == null) {
            fromContact = contactRepository.save(new Contact(fromPhoneNumber, ""));
        }

        Contact toContact = contactRepository.findByPhoneNumber(toPhoneNumber);

        if (toContact == null) {
            toContact = contactRepository.save(new Contact(toPhoneNumber, ""));
        }

        TextMessage textMessage = new TextMessage(
                body,
                false,
                toContact,
                fromContact
        );

        TextMessage savedTextMessage = textMessageRepository.save(textMessage);

        textMessageGateway.send(savedTextMessage);

        savedTextMessage.setDeliveredAt(new Date());

        TextMessage deliveredTextMessage = textMessageRepository.save(savedTextMessage);

        return deliveredTextMessage;
    }

    public TextMessage recordReceipt(String fromPhoneNumber, String toPhoneNumber, String body) {
        Contact fromContact = contactRepository.findByPhoneNumber(fromPhoneNumber);

        if (fromContact == null) {
            fromContact = contactRepository.save(new Contact(fromPhoneNumber, ""));
        }

        Contact toContact = contactRepository.findByPhoneNumber(toPhoneNumber);

        if (toContact == null) {
            toContact = contactRepository.save(new Contact(toPhoneNumber, ""));
        }

        TextMessage textMessage = new TextMessage(
                body,
                true,
                toContact,
                fromContact
        );

        textMessage.setDeliveredAt(new Date());

        TextMessage savedTextMessage = textMessageRepository.save(textMessage);

        return savedTextMessage;
    }
}
