package com.textchat.textmessages;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.persistence.textmessages.TextMessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
public class OtherTextMessagesController {
    private TextMessageRepository textMessageRepository;
    private ContactRepository contactRepository;

    @Autowired
    public OtherTextMessagesController(TextMessageRepository textMessageRepository, ContactRepository contactRepository) {
        this.textMessageRepository = textMessageRepository;
        this.contactRepository = contactRepository;
    }

    @GetMapping("/contacts/{contactId}/text-messages")
    @PreAuthorize("hasAuthority('USER')")
    public List<TextMessageResponse> listTextMessagesForContact(@PathVariable Long contactId) {
        Contact contact = contactRepository.findOne(contactId);

        return textMessageRepository
                .findAllByToContactOrderByCreatedAtDesc(contact)
                .stream()
                .map(TextMessageResponse::new)
                .collect(Collectors.toList());
    }
}
