package com.textchat;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ContactController {
    private ContactRepository contactRepository;

    @Autowired
    public ContactController(ContactRepository contactRepository) {
        this.contactRepository = contactRepository;
    }

    @PutMapping("/contacts")
    public void update(@RequestBody UpdateContactRequest updateContactRequest) {
        Contact contact = contactRepository.findByPhoneNumber(updateContactRequest.getPhoneNumber());

        contact.setLabel(updateContactRequest.getLabel());

        contactRepository.save(contact);
    }

    private static class UpdateContactRequest {
        private String phoneNumber;
        private String label;

        public String getPhoneNumber() {
            return phoneNumber;
        }

        public String getLabel() {
            return label;
        }
    }
}