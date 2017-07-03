package com.textchat;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactReadRepository;
import com.textchat.persistence.contacts.ContactRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ContactReadController {
    private ContactReadRepository contactReadRepository;
    private ContactRepository contactRepository;
//    private UserRepository userRepository;

    @Autowired
    public ContactReadController(
            ContactReadRepository contactReadRepository,
            ContactRepository contactRepository
//            UserRepository userRepository
    ) {
        this.contactReadRepository = contactReadRepository;
        this.contactRepository = contactRepository;
//        this.userRepository = userRepository;
    }

    // TODO make it return something
    @PostMapping("/contact-reads")
    public void create(ContactReadRequest contactReadRequest) {
//        User user = userRepository.findOne(1L);
        Contact contact = contactRepository.findOne(contactReadRequest.getContactId());

//        ContactRead contactRead = new ContactRead(contact, user, new Date());
//        contactReadRepository.save(contactRead);
    }
}
